//
//  ContentView.swift
//  TurnTable
//
//  Created by jon on 2025-06-18.
//

import Foundation
import SwiftUI
import CoreData
import AVKit
import AVFoundation
import AppKit

extension String {
    func version() -> String { return "1.1.151" }
}

struct mdat: Identifiable {
    let id = UUID()
    let path: String
    let song: String
    let band: String
    let albm: String
    let genr: String
    let year: String
    let tstr: String
    let date: String
    let null: String
    let hash: String
    let dobj: Date
    let time: Int64
}

struct slid: View {
    @Binding var locks: Bool
    @Binding var edits: Bool
    @Binding var moved: Bool
    @Binding var value: Double
    @Binding var colrg: Color
    @Binding var colrb: Color
    @Binding var highg: Color
    @Binding var highb: Color

    var fills: Bool

    @State var cobjg: Color?
    @State var cobjb: Color?
    @State var coord: CGFloat = 0.0
    @State var brite: CGFloat = 0.19

    var body: some View {
        GeometryReader { gr in
            let radial = (gr.size.height * 0.87)
            let radius = (gr.size.height * 0.69)
            let minval = (gr.size.width * 0.005)
            let maxval = ((gr.size.width * 0.995) - radial)

            ZStack {
                RoundedRectangle(cornerRadius:radius)
                    .inset(by:-1.99)
                    .stroke((cobjg == nil) ? colrg : cobjg!, lineWidth:1.59)
                    .brightness((cobjg == nil) ? 0.00 : brite)
                    .overlay(ZStack {
                        if (!fills) {
                            RoundedRectangle(cornerRadius:radius).inset(by:-1.09).foregroundColor(Color.black.opacity(0.11))
                        }
                        HStack {
                            if (fills) {
                                Rectangle().frame(width:1.0, height:1.0).foregroundColor(Color.clear).overlay(
                                    RoundedRectangle(cornerRadius:radius)
                                        .inset(by:-1.09)
                                        .foregroundColor((cobjb == nil) ? colrb : cobjb!).opacity(0.35)
                                        .frame(width:safes(valus:self.value, minms:minval, maxms:maxval, divrs:1.0)+(radial/1.1), height:radial)
                                        .offset(x:(safes(valus:self.value, minms:minval, maxms:maxval, divrs:1.0)/2.0)+(radial/2.1), y:0.0)
                                )
                                Spacer()
                            }
                        }})
                HStack {
                    Circle()
                        .foregroundColor((cobjb == nil) ? colrb : cobjb!)
                        .brightness(0.19)
                        .brightness((cobjg == nil) ? 0.00 : brite)
                        .frame(width:radial, height:radial)
                        .offset(x:safes(valus:self.value, minms:minval, maxms:maxval, divrs:1.0), y:0.0)
                        .gesture(
                            DragGesture(minimumDistance:0)
                                .onChanged { v in
                                    if (!locks) {
                                        self.edits = true
                                        self.cobjg = self.highg
                                        self.cobjb = self.highb
                                        if (abs(v.translation.width) < 0.1) {
                                            self.coord = safes(valus:self.value, minms:minval, maxms:maxval, divrs:1.0)
                                        }
                                        let temps = (self.coord + v.translation.width)
                                        self.value = safes(valus:temps, minms:minval, maxms:maxval, divrs:maxval) / maxval
                                    }
                                }
                                .onEnded() { v in
                                    if (!locks) {
                                        self.edits = false
                                        self.cobjg = nil
                                        self.cobjb = nil
                                    }
                                }
                        )
                    Spacer()
                }
            }.gesture(
                DragGesture(minimumDistance:0)
                    .onChanged { v in
                        if (!locks) {
                            self.edits = true
                            self.cobjg = self.highg
                            self.cobjb = self.highb
                            let temps = ((v.location.x - (radial / 2)) / maxval)
                            let valus = max(0.0, min(temps, 1.0))
                            self.value = valus
                            self.moved = true
                        }
                    }
                    .onEnded() { v in
                        if (!locks) {
                            self.edits = false
                            self.cobjg = nil
                            self.cobjb = nil
                        }
                    }
            )
        }
    }

    func safes(valus:Double, minms:Double, maxms:Double, divrs:Double) -> Double {
        if (locks) { return minms }
        return min(maxms, max(minms, valus * (maxms / divrs)))
    }
}

struct TextFieldClearButton: ViewModifier {
    @Binding var fieldText: String

    func body(content: Content) -> some View {
        content
            .overlay {
                if !fieldText.isEmpty {
                    HStack {
                        Spacer()
                        Button {
                            fieldText = ""
                        } label: {
                            Image(systemName: "multiply.circle.fill")
                        }
                        .buttonStyle(.borderless)
                        .offset(x:23.0)
                    }
                }
            }
    }
}

extension String {
    func lpadr(toLength: Int, withPad: String, padSide: Int) -> String {
        var tmpStr = self
        while (tmpStr.count < toLength) {
            if (padSide == 0) {
                tmpStr = (withPad + tmpStr)
            } else {
                tmpStr = (tmpStr + withPad)
            }
        }
        return tmpStr
    }
    func fstrs(char:String) -> String {
        return ((self.count > 0) && (String(Array(self)[self.count-1]) == char)) ? String(self.dropLast()) : self
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    func hexs(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
    func id3g(id3t:String?) -> String {
        let l = [
            "Blues", "Classic Rock", "Country", "Dance", "Disco", "Funk", "Grunge", "Hip-Hop", "Jazz", "Metal",
            "New Age", "Oldies", "Other", "Pop", "R&B", "Rap", "Reggae", "Rock", "Techno", "Industrial",
            "Alternative", "Ska", "Death Metal", "Pranks", "Soundtrack", "Euro-Techno", "Ambient", "Trip-Hop", "Vocal", "Jazz+Funk",
            "Fusion", "Trance", "Classical", "Instrumental", "Acid", "House", "Game", "Sound Clip", "Gospel", "Noise",
            "AlternRock", "Bass", "Soul", "Punk", "Space", "Meditative", "Instrumental Pop", "Instrumental Rock", "Ethnic", "Gothic",
            "Darkwave", "Techno-Industrial", "Electronic", "Pop-Folk", "Eurodance", "Dream", "Southern Rock", "Comedy", "Cult", "Gangsta Rap",
            "Top 40", "Christian Rap", "Pop / Funk", "Jungle", "Native American", "Cabaret", "New Wave", "Psychedelic", "Rave", "Showtunes",
            "Trailer", "Lo-Fi", "Tribal", "Acid Punk", "Acid Jazz", "Polka", "Retro", "Musical", "Rock & Roll", "Hard Rock",
            "Folk", "Folk-Rock", "National Folk", "Swing", "Fast Fusion", "Bebob", "Latin", "Revival", "Celtic", "Bluegrass",
            "Avantgarde", "Gothic Rock", "Progressive Rock", "Psychedelic Rock", "Symphonic Rock", "Slow Rock", "Big Band", "Chorus", "Easy Listening", "Acoustic",
            "Humour", "Speech", "Chanson", "Opera", "Chamber Music", "Sonata", "Symphony", "Booty Bass", "Primus", "Porn Groove",
            "Satire", "Slow Jam", "Club", "Tango", "Samba", "Folklore", "Ballad", "Power Ballad", "Rhythmic Soul", "Freestyle",
            "Duet", "Punk Rock", "Drum Solo", "A Cappella", "Euro-House", "Dance Hall", "Goa", "Drum & Bass", "Club-House", "Hardcore",
            "Terror", "Indie", "BritPop", "Negerpunk", "Polsk Punk", "Beat", "Christian Gangsta Rap", "Heavy Metal", "Black Metal", "Crossover",
            "Contemporary Christian", "Christian Rock", "Merengue", "Salsa", "Thrash Metal", "Anime", "JPop", "Synthpop", "Abstract", "Art Rock",
            "Baroque", "Bhangra", "Big Beat", "Breakbeat", "Chillout", "Downtempo", "Dub", "EBM", "Eclectic", "Electro",
            "Electroclash", "Emo", "Experimental", "Garage", "Global", "IDM", "Illbient", "Industro-Goth", "Jam Band", "Krautrock",
            "Leftfield", "Lounge", "Math Rock", "New Romantic", "Nu-Breakz", "Post-Punk", "Post-Rock", "Psytrance", "Shoegaze", "Space Rock",
            "Trop Rock", "World Music", "Neoclassical", "Audiobook", "Audio Theatre", "Neue Deutsche Welle", "Podcast", "Indie Rock", "G-Funk", "Dubstep",
            "Garage Rock", "Psybient"
        ]
        var i = -1
        if (id3t != nil) {
            let n = Int(id3t!)
            if (n != nil) { i = n! }
            if ((i <= -1) || (l.count <= i)) {
                return id3t!
            }
        } else {
            let h = self.hexs()
            let n = Int(strtoul(h, nil, 16))
            i = (n - 1)
        }
        if ((-1 < i) && (i < l.count)) {
            return l[i]
        }
        return "---"
    }
}

extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
    func genr(inpt:[String], size:Int) -> [[String]] {
        var outp = [] as [[String]]
        var iidx = 0
        while (iidx < size) {
            outp.append(inpt)
            iidx += 1
        }
        return outp
    }
}

extension View {
    func showClearButton(_ text: Binding<String>) -> some View {
        self.modifier(TextFieldClearButton(fieldText: text))
    }
}

class note: NotificationCenter, @unchecked Sendable {

    @AppStorage("ClassBook")
    var book: Data?

    var view: ContentView?
    let lock = NSLock()
    let quel = NSLock()
    var ldat = Date(timeIntervalSince1970:0)
    var inil = [] as [String]
    var coaa = [] as [String]
    var coab = [] as [mdat]
    var coba = [] as [String]
    var cobb = [] as [mdat]
    var coca = [] as [String]
    var cocb = [] as [mdat]
    var tabp = [] as [mdat]
    var tabt = [] as [mdat]
    var pobj: AVPlayerItem?
    var plyr = AVPlayer()
    var sele: mdat?
    var save: mdat?
    var selx: UUID?
    var stal = true
    var outp = ""
    var flag = 0
    var stat = 0
    var load = 0
    var loas = 0
    var last = 0
    var indx = -1

    required override init() {
        print(Date(),"DEBUG","init")
    }

    func main(objc:ContentView) {
        let lets = "0123456789ACBDEF"
        let rnds = String((0..<8).map{ _ in lets.randomElement()! })
        if (inil.isEmpty) {
            inil.append(rnds)
            view = objc
            print(Date(),"DEBUG","rand",rnds)
            DispatchQueue.global(qos:.background).async { self.loop() }
        }
    }

    func glob() -> NSLock {
        return lock
    }

    func sync(inpt:[mdat]) {
        tabp = inpt
    }

    func xfer(inpt:UUID?) {
        if (inpt != nil) { selx = inpt! }
    }

    func mkda() -> Data {
        return "".data(using:.utf8)!
    }

    func geth() -> mdat? {
        if ((-1 < indx) && (indx < tabp.count)) {
            return tabp[indx]
        }
        return nil
    }

    func getu(inpt:mdat?) -> UUID {
        if (inpt != nil) { return inpt!.id }
        return UUID()
    }

    func divs(a:Int64, b:Int64) -> Int64 {
        if (b < 1) { return 0 }
        return (a / b)
    }

    func form(inpt:Int64) -> String {
        let mins = (inpt / 60)
        let secs = (inpt % 60)
        return String(format:"%02d:%02d", mins, secs)
    }

    func mods(path:String, back:String) -> Date? {
        do {
            let purl = URL(fileURLWithPath:path)
            let attr = try FileManager.default.attributesOfItem(atPath:purl.path)
            let dobj = attr[FileAttributeKey.modificationDate] as? Date
            return dobj!
        } catch {
            return nil
        }
    }

    func exec(_ comd: String) throws -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", comd]
        task.executableURL = URL(fileURLWithPath:"/bin/bash")
        task.standardInput = nil

        try task.run()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let temp = String(data:data, encoding:.utf8)!

        return temp
    }

    func gets() -> Int {
        if ((stat == 1) || (stat == 9)) {
            if (plyr.timeControlStatus != AVPlayer.TimeControlStatus.playing) {
                if (stat == 9) { return 1 }
                return -1
            }
            if (stat == 9) { stat = 1 }
        }
        return stat
    }

    func make(path:String, song:String, band:String, albm:String, genr:String, year:String, tstr:String, null:String, dobj:Date, time:Int64) -> mdat {
        let form = DateFormatter()
        form.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date = form.string(from:dobj)
        let hash = "song:\(song), band:\(band), albm:\(albm), genr:\(genr), year:\(year), time:\(tstr), date:\(date), path:\(path)"
        return mdat(path:path, song:song, band:band, albm:albm, genr:genr, year:year, tstr:tstr, date:date, null:null, hash:hash, dobj:dobj, time:time)
    }

    func gens(inpt:String) -> [KeyPathComparator<mdat>] {
        let lows = inpt.lowercased()
        let dirs = lows.contains("reverse") ? SortOrder.reverse : SortOrder.forward
        if (lows.contains("song")) { return [KeyPathComparator(\mdat.song, order:dirs)] }
        if (lows.contains("albm")) { return [KeyPathComparator(\mdat.albm, order:dirs)] }
        if (lows.contains("genr")) { return [KeyPathComparator(\mdat.genr, order:dirs)] }
        if (lows.contains("year")) { return [KeyPathComparator(\mdat.year, order:dirs)] }
        if (lows.contains("tstr")) { return [KeyPathComparator(\mdat.tstr, order:dirs)] }
        if (lows.contains("date")) { return [KeyPathComparator(\mdat.date, order:dirs)] }
        return [KeyPathComparator(\mdat.band, order:dirs)]
    }

    func loop() {
        let objc = view!
        let opap = \ContentView.opap
        let prog = \ContentView.prog
        let time = \ContentView.time
        let tabl = \ContentView.tabl
        let baup = \ContentView.baup
        let hold = \ContentView.hold
        let sels = \ContentView.sels
        let srch = \ContentView.srch
        let srts = \ContentView.srts
        let srtz = \ContentView.srtz
        let slir = \ContentView.slir
        let xfru = \ContentView.xfru
        let rotf = \ContentView.rotf
        let rota = \ContentView.rota
        let coad = \ContentView.coad
        let cobd = \ContentView.cobd
        let cocd = \ContentView.cocd
        let cobt = \ContentView.cobt
        let coct = \ContentView.coct
        var csec = Int64(0)
        var cstr = form(inpt:csec)
        var tsec = Int64(0)
        var tstr = form(inpt:tsec)
        var psec = Double(0.0)
        var seek = 0
        var menl = 0
        while (0 == 0) {
            let secs = Int(Date().timeIntervalSince1970)
            if ((secs - load) >= (15 * 60)) {
                load = secs
                flag = 0
                loas = 1
                outp = ""
                save = geth()
                objc[keyPath:opap] = 1.00
                DispatchQueue.global(qos:.background).async { self.proc() }
            }
            let chks = gets()
            if (chks > 0) { objc[keyPath:slir][0] = false }
            else { objc[keyPath:slir][0] = true }
            if ((chks == 1) && (objc[keyPath:rotf] != 1)) { objc[keyPath:rota] = 0.0 ; objc[keyPath:rotf] = 1 }
            else if ((chks != 1) && (objc[keyPath:rotf] != 0)) { objc[keyPath:rota] = 360.0 ; objc[keyPath:rotf] = 0 }
            if ((stat == 1) && (chks < 0)) {
                let _ = next(iidx:1, over:1)
            }
            if ((stat == 1) && (chks == 1)) {
                let cobj = plyr.currentTime()
                csec = divs(a:Int64(cobj.value), b:Int64(cobj.timescale))
                let hobj = geth()
                if (hobj != nil) { tsec = hobj!.time }
                if (tsec < 1) { tsec = 1 }
            }
            if (tsec > 1) {
                if (pobj == nil) { csec = 0 }
                if (objc[keyPath:slir][2]) {
                    objc[keyPath:slir][2] = false
                    seek = 1
                }
                if (objc[keyPath:slir][1] || (seek != 0)) {
                    seek = 1
                    psec = (Double(objc[keyPath:prog]) * Double(tsec))
                    csec = Int64(psec)
                    cstr = form(inpt:csec)
                    objc[keyPath:time][0] = cstr
                    if (!objc[keyPath:slir][1]) {
                        if (csec >= 0) {
                            plyr.seek(to:CMTime(seconds:Double(csec), preferredTimescale:CMTimeScale(1)))
                        }
                        seek = 0
                    }
                } else if (objc[keyPath:prog] <= 1.0) {
                    cstr = form(inpt:csec)
                    tstr = form(inpt:tsec)
                    psec = (Double(csec) / Double(tsec))
                    objc[keyPath:prog] = psec
                    objc[keyPath:time][0] = cstr
                    objc[keyPath:time][1] = tstr
                }
            }
            let numt = tabt.count
            let numb = tabp.count
            let nump = objc[keyPath:baup].count
            let numq = objc[keyPath:tabl].count
            if ((numt > 0) && (loas == 2)) {
                if ((secs - last) >= 3) {
                    let nils = "---"
                    let dumb = make(path:nils, song:nils, band:nils, albm:nils, genr:nils, year:nils, tstr:nils, null:nils, dobj:Date(), time:0)
                    let gsrt = gens(inpt:objc[keyPath:srtz])
                    if (flag == 1) {
                        lock.withLock {
                            print(Date(),"DEBUG","xfer",numt,numb,nump,numq,ldat)
                            tabp = tabt
                            tabp.sort(using:gsrt)
                            coaa = [nils] ; coab = [dumb]
                            coba = [nils] ; cobb = [dumb]
                            coca = [nils] ; cocb = [dumb]
                            objc[keyPath:srts] = gsrt
                            objc[keyPath:baup] = tabp
                            if (objc[keyPath:srch] == "") {
                                objc[keyPath:tabl] = objc[keyPath:baup]
                            }
                            var iidx = 0
                            for item in tabp {
                                if (sele != nil) {
                                    if (item.hash == sele!.hash) {
                                        objc[keyPath:sels].removeAll()
                                        objc[keyPath:sels].insert(item.id)
                                    }
                                }
                                if (save != nil) {
                                    if (item.hash == save!.hash) {
                                        indx = iidx
                                        objc[keyPath:xfru] = item.id
                                    }
                                }
                                if (!(coaa.contains(item.band))) { coaa.append(item.band) ; coab.append(item) }
                                if (!(coba.contains(item.albm))) { coba.append(item.albm) ; cobb.append(item) }
                                if (!(coca.contains(item.genr))) { coca.append(item.genr) ; cocb.append(item) }
                                iidx = (iidx + 1)
                            }
                            coab.sort(using:gens(inpt:"band"))
                            cobb.sort(using:gens(inpt:"albm"))
                            cocb.sort(using:gens(inpt:"genr"))
                            objc[keyPath:coad] = coab
                            objc[keyPath:cobd] = cobb
                            objc[keyPath:cocd] = cocb
                            objc[keyPath:cobt] = cobb
                            objc[keyPath:coct] = cocb
                        }
                    }
                    tabt.removeAll()
                    objc[keyPath:opap] = 0.00
                    loas = 3
                    last = secs
                }
            }
            if (getu(inpt:geth()) != getu(inpt:objc[keyPath:hold])) {
                objc[keyPath:hold] = geth()
            }
            if (selx != nil) {
                if ((sele == nil) || (sele!.id != selx!)) {
                    for item in tabp {
                        if (item.id == selx!) {
                            sele = item
                        }
                    }
                }
            }
            if ((secs - menl) >= 3) {
                DispatchQueue.main.async {
                    if let wind = NSApp.windows.first {
                        wind.backgroundColor = NSColor(Color.clear)
                    }
                    let menu = NSApplication.shared.mainMenu
                    if (menu?.item(withTitle:"Data") == nil) {
                        let item: NSMenuItem? = menu?.item(withTitle:"Help")
                        if let item {
                            menu?.removeItem(item)
                        }
                        let meni = NSMenuItem(title:"Load", action:#selector(self.refr(_:)), keyEquivalent:"")
                        meni.isEnabled = true
                        meni.target = self
                        let mend = NSMenuItem(title:"Data", action:nil, keyEquivalent:"")
                        mend.isEnabled = true
                        mend.target = self
                        mend.submenu = NSMenu(title:"Data")
                        mend.submenu?.autoenablesItems = true
                        mend.submenu?.addItem(meni)
                        menu?.addItem(mend)
                        let menw = NSMenuItem(title:"Window", action:#selector(self.wdow(_:)), keyEquivalent:"")
                        menw.isEnabled = true
                        menw.target = self
                        let menf = NSMenuItem(title:"File", action:nil, keyEquivalent:"")
                        menf.isEnabled = true
                        menf.target = self
                        menf.submenu = NSMenu(title:"File")
                        menf.submenu?.autoenablesItems = true
                        menf.submenu?.addItem(menw)
                        menu?.insertItem(menf, at:1)
                    }
                }
                menl = secs
            }
            print(Date(),"DEBUG","loop",inil,cstr,tstr,psec,stat,chks,indx,load,numt,numb,nump,numq)
            usleep(450000)
        }
    }

    func play(mobj:mdat?, over:Int) -> Int {
        if (mobj != nil) {
            var iter = 0
            var iidx = -9
            for item in tabp {
                if (item.path == mobj!.path) {
                    iidx = iter
                }
                iter = (iter + 1)
            }
            if (iidx > -1) { indx = iidx }
            if (mods(path:mobj!.path, back:"") == nil) { iidx = -8 }
            if (iidx < 0) { return iidx }
            if (over == 1) {
                let purl = URL(fileURLWithPath:mobj!.path)
                pobj = AVPlayerItem(url:purl)
                plyr = AVPlayer(playerItem:pobj)
                plyr.play()
                stat = 9
            }
        } else {
            plyr.play()
            stat = 9
        }
        return gets()
    }

    func stop() {
        if (gets() == 1) {
            plyr.pause()
            stat = 2
        }
    }

    func halt(high:Int) {
        stop()
        pobj = nil
        stat = 0
    }

    func next(iidx:Int, over:Int) -> Int {
        let objc = view!
        let tabl = \ContentView.tabl
        let shuf = \ContentView.shuf
        var jidx = 0
        var zidx = iidx
        var chks = gets()
        let pres = geth()
        let leng = objc[keyPath:tabl].count
        halt(high:0)
        if (tabp.count < 1) { return -1 }
        if (leng < 1) { return -2 }
        if (pres != nil) {
            var i = 0
            for item in objc[keyPath:tabl] {
                if (item.hash == pres!.hash) { jidx = i }
                i = (i + 1)
            }
        }
        if (objc[keyPath:shuf][0] || objc[keyPath:shuf][1]) { zidx = Int.random(in:1..<leng) }
        jidx = (jidx + zidx)
        if (jidx < 0) { jidx = (leng - 1) }
        jidx = (jidx % leng)
        if (over == 1) { chks = over }
        let _ = play(mobj:objc[keyPath:tabl][jidx], over:chks)
        return gets()
    }

    func chkb() -> URL? {
        if (book != nil) {
            do {
                let temp = try URL(
                    resolvingBookmarkData:book!,
                    options:.withSecurityScope,
                    relativeTo: nil,
                    bookmarkDataIsStale:&stal
                )
                print(Date(),"DEBUG","book",temp,temp.relativePath,book!,stal)
                return temp
            } catch {
                /* no-op */
            }
        } else {
            stal = true
        }
        return nil
    }

    func proc() {
        var slee = 0
        while (outp == "") {
            var burl = chkb()
            if ((burl == nil) || (book == nil) || (stal == true) || (slee == 1)) {
                slee = 2
                book = nil
                DispatchQueue.main.async {
                    let opan = NSOpenPanel()
                    opan.allowsMultipleSelection = false
                    opan.canChooseDirectories = true
                    opan.canCreateDirectories = false
                    opan.canChooseFiles = false
                    let chek = opan.runModal()
                    if (chek == NSApplication.ModalResponse.OK) {
                        let curl = opan.url!
                        print(Date(),"DEBUG","open",curl)
                        do {
                            self.book = try curl.bookmarkData(
                                options:.withSecurityScope,
                                includingResourceValuesForKeys:nil,
                                relativeTo:nil
                            )
                        } catch {
                            /* no-op */
                        }
                    }
                }
            }
            burl = chkb()
            if (burl != nil) {
                if (burl!.startAccessingSecurityScopedResource()) {
                    //let fold = (NSString(string:"~").expandingTildeInPath + "/Music")
                    let fold = burl!.relativePath
                    let path = String(format:"find '%@/' -type f 2>&1 | grep -Ei '(mp3|m4a)$'", fold)
                    print(Date(),"DEBUG","list",load,fold)
                    if let temp = try? exec(path) {
                        outp = temp.trimmingCharacters(in:.whitespaces)
                        if (outp != "") {
                            var iidx = 0
                            let mtmp = make(path:"", song:"", band:"", albm:"", genr:"", year:"", tstr:"", null:"", dobj:Date(), time:0)
                            let list = outp.components(separatedBy:"\n").filter { !$0.isEmpty }
                            tabt.removeAll()
                            for _ in list { tabt.append(mtmp) }
                            for line in list {
                                meta(iidx:iidx, path:line)
                                iidx = (iidx + 1)
                            }
                            iidx = 0
                            while (iidx < list.count) {
                                usleep(650000)
                                quel.withLock {
                                    while (tabt[iidx].path != "") {
                                        if (tabt[iidx].dobj > ldat) { ldat = tabt[iidx].dobj ; flag = 1 }
                                        iidx += 1
                                        if (iidx >= list.count) { break }
                                    }
                                }
                                print(Date(),"DEBUG","wait",iidx,list.count)
                            }
                        }
                    }
                    burl!.stopAccessingSecurityScopedResource()
                }
            }
            if (slee == 0) { slee = 1 }
            if ((outp == "") && (slee != 0)) { sleep(5) }
        }
        loas = 2
    }

    func dats(inpt:[[Any]]) -> [[Any]] {
        var info = [] as [[Any]]
        var i = 0
        for _ in inpt {
            var item = (inpt[i][0] as? NSString) as String? ?? ""
            if (item == "") { item = "---" }
            info.append([item, inpt[i][1]])
            i = (i + 1)
        }
        let temp = mkda()
        info[3][0] = temp.id3g(id3t:info[3][0] as? String)
        let chek = info[3][0] as? String
        if (chek == "---") {
            let dval = (inpt[3][1] as? NSData) as Data? ?? temp
            info[3][0] = dval.id3g(id3t:nil)
        }
        return info
    }

    func meta(iidx:Int, path:String) {
        let purl = URL(fileURLWithPath:path)
        let aset = AVURLAsset(url:purl)
        Task {
            let maps = [[0, "©nam"], [1, "©ART"], [2, "©alb"], [3, "©gen"], [4, "©day"]]
            var info = [["", mkda()], ["", mkda()], ["", mkda()], ["", mkda()], ["", mkda()]]
            let dobj = try await aset.load(.duration)
            let data = try await aset.load(.metadata)
            let itun = try await aset.loadMetadata(for:AVMetadataFormat.iTunesMetadata)
            for item in data {
                if let name = item.commonKey?.rawValue, let vals = try await item.load(.value) {
                    if (name == "title") {
                        info[0][0] = vals
                        info[0][1] = vals
                    }
                    if (name == "artist") {
                        info[1][0] = vals
                        info[1][1] = vals
                    }
                    if (name == "albumName") {
                        info[2][0] = vals
                        info[2][1] = vals
                    }
                    if (name == "type") {
                        info[3][0] = vals
                        info[3][1] = vals
                    }
                } else if let name = item.key?.description, let vals = try await item.load(.value) {
                    if (name == "TPE2") {
                        info[1][0] = vals
                        info[1][1] = vals
                    }
                }
            }
            var minf = dats(inpt:info)
            for imap in maps {
                let i = imap[0] as? Int ?? 0
                let k = imap[1] as? String ?? ""
                let z = minf[i][0] as? String
                if (z == "---") {
                    let item = AVMetadataItem.metadataItems(from:itun, withKey:k, keySpace:AVMetadataKeySpace.iTunes)
                    if let name = item.first, let vals = try await name.load(.value) {
                        info[i][0] = vals
                        info[i][1] = vals
                    }
                    let temp = dats(inpt:info)
                    minf[i][0] = temp[i][0]
                    minf[i][1] = temp[i][1]
                }
            }
            let csec = divs(a:Int64(dobj.value), b:Int64(dobj.timescale))
            let tsec = form(inpt:csec)
            let modd = mods(path:path, back:"---")
            var dmod = Date()
            if (modd != nil) { dmod = modd! }
            let temp = make(path:path, song:(minf[0][0] as! String), band:(minf[1][0] as! String), albm:(minf[2][0] as! String), genr:(minf[3][0] as! String), year:(minf[4][0] as! String), tstr:tsec, null:"*", dobj:dmod, time:csec)
            if (iidx > -1) {
                quel.withLock {
                    self.tabt[iidx] = temp
                }
            }
        }
    }

    @MainActor func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }

    @objc func refr(_ sender: Any) {
        if ((loas == 0) || (loas == 3)) {
            ldat = Date(timeIntervalSince1970:0)
            load = 0
        }
    }

    @objc func wdow(_ sender: Any) {
        DispatchQueue.main.async {
            let wind = NSApplication.shared.windows
            if let main = wind.first {
                if let savd = UserDefaults.standard.string(forKey:"WindowFrame") {
                    main.setFrame(from:savd)
                    main.makeKeyAndOrderFront(nil)
                } else {
                    main.makeKeyAndOrderFront(nil)
                }
            }
        }
    }

}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @AppStorage("TableColumn")
    var cols: TableColumnCustomization<mdat>

    @AppStorage("TableSort")
    var srtz: String = "name"

    @AppStorage("TablePlaylist")
    var plst: [[String]] = []

    @AppStorage("TableShop")
    var shwp = false

    @AppStorage("TableShow")
    var tsho: String = "no"

    @AppStorage("TableShof")
    var shuf = [false, false]

    @AppStorage("ColorBase")
    var cbno = [0.0, 0.0, 0.0, 0.0, 0.0]

    @AppStorage("ColorHigh")
    var chno = [0.0, 0.0, 0.0, 0.0, 0.0]

    @AppStorage("ColorText")
    var ctno = [0.0, 0.0, 0.0, 0.0, 0.0]

    @AppStorage("ColorTint")
    var cuno = [0.0, 0.0, 0.0, 0.0, 0.0]

    @AppStorage("ColorView")
    var cvno = [0.0, 0.0, 0.0, 0.0, 0.0]

    @AppStorage("ColorList")
    var clno = [0.0, 0.0, 0.0, 0.0, 0.0]

    @AppStorage("ColorBlur")
    var crno = [0.0, 0.0, 0.0, 0.0, 0.0]

    @AppStorage("WindowSetting")
    var wini = [97.0, 0.0, 0.19]

    @AppStorage("PlayerVolume")
    var volu = [1.00, 1.00, 1.00]

    @FocusState private var isfo: Bool

    @State var clrs = [""].genr(inpt:["b", "g", "b", "!", "", ""], size:1000)
    @State var idxs = [1 /*play*/, 3 /*shuf*/, 4 /*show*/, 50 /*filt*/, 51 /*list*/, 55 /*stat*/, 75 /*volu*/, 99 /*icon*/]

    @State var imgl = 0
    @State var imgd: Image?
    @State var winl = [Color.clear, Material.ultraThin, Material.thin, Material.regular, Material.thick, Material.ultraThick]
    @State var wins = 0
    @State var winc = Color.clear
    @State var sldr = [Color.clear, Color.clear, Color.clear, Color.clear]
    @State var sldv = [Color.clear, Color.clear, Color.clear, Color.clear]
    @State var cbco = Color.clear
    @State var chco = Color.clear
    @State var ctco = Color.clear
    @State var cuco = Color.clear
    @State var cvco = Color.clear
    @State var clco = Color.clear
    @State var crco = Color.clear
    @State var bldr = [["band"], ["albm"], ["genr"], ["year"]]
    @State var time = ["00:00", "00:00"]
    @State var mode = "play.circle"
    @State var prog = 0.00
    @State var opap = 0.00
    @State var rotf = 0
    @State var rota = 360.0
    @State var shws = false
    @State var fals = true
    @State var mute = true
    @State var slir = [true, false, false]
    @State var sliv = [false, false, false]
    @State var srch = ""
    @State var name = ""
    @State var last = 0
    @State var relo = [0, 0]
    @State var pidx = -1
    @State var xfrs: UUID?
    @State var xfru: UUID?
    @State var sell: UUID?
    @State var hold: mdat?
    @State var tabl = [] as [mdat]
    @State var baup = [] as [mdat]
    @State var sels = Set<mdat.ID>()
    @State var srts = [] as [KeyPathComparator<mdat>]
    @State var coad = [] as [mdat]
    @State var coas = Set<mdat.ID>()
    @State var cobd = [] as [mdat]
    @State var cobt = [] as [mdat]
    @State var cobs = Set<mdat.ID>()
    @State var cocd = [] as [mdat]
    @State var coct = [] as [mdat]
    @State var cocs = Set<mdat.ID>()
    @State var nobj = note()

    var body: some View {
        let epad = 8.0
        let ssiz = [600.0, 92.0]

        ZStack {
            VStack {
                HStack {
                    VStack {
                        let offs = 1.99
                        HStack {
                            butv(kind:"arrow.left.circle", size:37.0, extr:[epad*1.15, 0.0], iidx:0, clst:["b", "g", "b", "!"], meth:-1, pram:-1, actn:prev)
                            butv(kind:mode, size:45.0, extr:[epad*1.15, 0.0], iidx:idxs[0], clst:["b", "g", "b", "*"], meth:-1, pram:-1, actn:bply)
                            butv(kind:"arrow.right.circle", size:37.0, extr:[epad*1.15, 0.0], iidx:2, clst:["b", "g", "b", "!"], meth:-1, pram:-1, actn:more)
                        }.offset(x:0.00, y:-1.99+offs).overlay(
                            butv(kind:"shuffle.circle", size:28.0, extr:[0.0, 0.0], iidx:idxs[1], clst:["b", "g", ((shuf[0] == false) && (shuf[1] == false)) ? "b" : "g", "*"], meth:-1, pram:-1, actn:shfs)
                                .offset(x:103.99, y:-2.19+offs)
                            )
                        HStack {  }.overlay(
                            HStack {
                                let spcr = 1.75
                                butv(kind:(mute == false) ? "speaker.circle" : "speaker.slash.circle", size:24.0, extr:[epad*spcr, 0.0], iidx:idxs[6], clst:["b", "g", "b", "~"], meth:-1, pram:-1, actn:minv)
                                slid(locks:$sliv[0], edits:$sliv[1], moved:$sliv[2], value:$volu[0], colrg:$sldv[0], colrb:$sldv[1], highg:$sldv[2], highb:$sldv[3], fills:true).frame(width:155.0, height:11.0).offset(y:0.99).onAppear {
                                    sldv = [colr(k:"b"), colr(k:"b"), colr(k:"bh"), colr(k:"bh")]
                                }.onContinuousHover { phase in
                                    switch phase {
                                    case .active:
                                        sldv = [colr(k:"bh"), colr(k:"bh"), colr(k:"bh"), colr(k:"bh")]
                                    case .ended:
                                        DispatchQueue.main.asyncAfter(deadline:.now() + 0.31) {
                                            sldv = [colr(k:"b"), colr(k:"b"), colr(k:"bh"), colr(k:"bh")]
                                        }
                                    }
                                }.onChange(of:volu[0]) {
                                    volu[1] = volu[0]
                                    if (volu[1] < 0.09) { volu[1] = 0.0 }
                                    if (volu[1] > 0.95) { volu[1] = 1.0 }
                                    nobj.plyr.volume = Float(volu[1])
                                }
                                butv(kind:"speaker.wave.2.circle", size:24.0, extr:[epad*spcr, 0.0], iidx:77, clst:["b", "g", "b", "!"], meth:-1, pram:-1, actn:maxv)
                            }.frame(width:1.0, height:1.0).offset(x:0.00, y:21.00-offs)
                        )
                    }.frame(width:250.0).offset(x:15.99, y:-15.99)
                    HStack {  }.padding(.leading, 28.0)
                    HStack {
                        ZStack {
                            let iidx = idxs[5]
                            RoundedRectangle(cornerRadius:19.0).fill(colr(k:"z")).frame(width:ssiz[0], height:ssiz[1]).overlay(ZStack {
                                RoundedRectangle(cornerRadius:21.0).stroke(colr(k:clrs[iidx][2]), lineWidth:3.9).opacity(0.91).frame(width:ssiz[0]+3.9, height:ssiz[1]+3.9)
                                VStack {
                                    txtv(strs:gets(kind:0), size:17.0, colr:colr(k:"t"), kind:0, bold:0).offset(y:-5.99).frame(width:ssiz[0]*0.89)
                                    txtv(strs:gets(kind:1), size:15.0, colr:colr(k:"t"), kind:0, bold:0).offset(y:-0.99).frame(width:ssiz[0]*0.75)
                                    HStack {
                                        txtv(strs:time[0], size:13.0, colr:colr(k:"t"), kind:1, bold:1).padding(.trailing, 8.0).offset(y:0.09)
                                        slid(locks:$slir[0], edits:$slir[1], moved:$slir[2], value:$prog, colrg:$sldr[0], colrb:$sldr[1], highg:$sldr[2], highb:$sldr[3], fills:false).frame(width:ssiz[0]*0.50, height:13.0).offset(y:-0.99).onAppear {
                                            sldr = [colr(k:"t"), colr(k:"b"), colr(k:"th"), colr(k:"bh")]
                                        }
                                        txtv(strs:time[1], size:13.0, colr:colr(k:"t"), kind:1, bold:1).padding(.leading, 8.0).offset(y:0.09)
                                    }.offset(y:0.99)
                                }.offset(y:0.99)
                                })
                        }.onContinuousHover { phase in
                            switch phase {
                            case .active:
                                sldr = [colr(k:"th"), colr(k:"bh"), colr(k:"th"), colr(k:"bh")]
                            case .ended:
                                DispatchQueue.main.asyncAfter(deadline:.now() + 0.39) {
                                    sldr = [colr(k:"t"), colr(k:"b"), colr(k:"th"), colr(k:"bh")]
                                }
                            }
                        }
                    }.frame(maxWidth:.infinity).frame(height:16.0).onTapGesture {
                        isfo = true
                    }
                    HStack {  }.padding(.leading, 21.0)
                    VStack {
                        let offs = 3.99
                        HStack {
                            let iidx = idxs[3]
                            TextField("Filter", text:$srch).disabled(fals).onAppear { DispatchQueue.main.async { fals = false } }
                                .onChange(of:srch) { olds, vals in
                                    last = Int(Date().timeIntervalSince1970)
                                    filt()
                                }
                                .frame(width:160.0)
                                .showClearButton($srch)
                                .foregroundColor(colr(k:"t"))
                                .disableAutocorrection(true)
                                .textFieldStyle(.plain)
                                .font(Font.custom("Menlo", size:15.0).weight(.bold))
                                .padding(EdgeInsets(top:1.5, leading:12.0, bottom:1.5, trailing:24.0))
                                .overlay(RoundedRectangle(cornerRadius:13.0).inset(by:-5.0).stroke(colr(k:clrs[iidx][2]), lineWidth:3.0))
                                .offset(x:3.99)
                            butv(kind:funp(iidx:4), size:30.0, extr:[0.0, 0.0], iidx:4, clst:["b", "g", (shwp == false) ? "b" : "g", "~"], meth:-1, pram:-1, actn:clkp).offset(x:12.0).overlay(
                                butv(kind:"multiply.circle", size:26.0, extr:[0.0, 0.0], iidx:5, clst:["b", "g", "b", "!"], meth:3, pram:3, actn:nill)
                                    .padding(.trailing, 1.0).padding(.top, 1.0).offset(x:13.00, y:41.00-offs))
                        }.offset(x:0.09, y:-1.99+offs)
                        HStack {  }.overlay(
                            HStack {
                                let spcr = 1.55
                                butv(kind:"star.circle", size:26.0, extr:[epad*spcr, 0.0], iidx:6, clst:["b", "g", "b", "!"], meth:-1, pram:-1, actn:star)
                                butv(kind:"viewfinder.circle", size:26.0, extr:[epad*spcr, 0.0], iidx:7, clst:["b", "g", "b", "!"], meth:-1, pram:-1, actn:fndr)
                                butv(kind:"line.3.horizontal.circle", size:26.0, extr:[epad*spcr, 0.0], iidx:8, clst:["b", "g", (tsho == "no") ? "b" : "g", "*"], meth:-1, pram:-1, actn:shot)
                                butv(kind:funs(iidx:9), size:26.0, extr:[epad*spcr, 0.0], iidx:9, clst:["b", "g", (shws == false) ? "b" : "g", "~"], meth:-1, pram:-1, actn:clks)
                            }.frame(width:1.0, height:1.0).offset(x:-11.00, y:29.00-offs)
                        )
                    }.offset(x:0.09, y:-17.99)
                    HStack {  }.padding(.leading, 36.0)
                }.padding(EdgeInsets(top:12.0, leading:0.0, bottom:38.0, trailing:0.0))
                colv()
                HStack {
                    ZStack {
                        ScrollViewReader { proxy in
                            Table(tabl, selection:$sels, sortOrder:$srts, columnCustomization:$cols) {
                                TableColumn(" ") { temp in
                                    let istr = ((hold == nil) || (temp.id != hold!.id)) ? "circle.dotted" : "star.circle"
                                    let isiz = ((hold == nil) || (temp.id != hold!.id)) ? 18.0 : 20.0
                                    txtv(strs:" ", size:15.0, colr:colr(k:"l"), kind:1, bold:1).overlay(ZStack {
                                        Image(systemName:istr).resizable().scaledToFit().frame(width:isiz, height:isiz).foregroundColor(colr(k:"l"))
                                    }.zIndex(11.0))
                                }.customizationID("*").alignment(.center)
                                TableColumn("Track", value:\.song) { temp in
                                    txtv(strs:temp.song, size:13.0, colr:colr(k:"l"), kind:0, bold:0)
                                }.customizationID("Track")
                                TableColumn("Artist", value:\.band) { temp in
                                    txtv(strs:temp.band, size:13.0, colr:colr(k:"l"), kind:0, bold:0)
                                }.customizationID("Artist")
                                TableColumn("Album", value:\.albm) { temp in
                                    txtv(strs:temp.albm, size:13.0, colr:colr(k:"l"), kind:0, bold:0)
                                }.customizationID("Album")
                                TableColumn("Genre", value:\.genr) { temp in
                                    txtv(strs:temp.genr, size:13.0, colr:colr(k:"l"), kind:0, bold:0)
                                }.customizationID("Genre")
                                TableColumn("Year", value:\.year) { temp in
                                    txtv(strs:temp.year, size:11.0, colr:colr(k:"l"), kind:1, bold:1)
                                }.customizationID("Year").alignment(.center)
                                TableColumn("Time", value:\.tstr) { temp in
                                    txtv(strs:temp.tstr, size:11.0, colr:colr(k:"l"), kind:1, bold:1)
                                }.customizationID("Time").alignment(.center)
                                TableColumn("Date", value:\.date) { temp in
                                    txtv(strs:temp.date, size:11.0, colr:colr(k:"l"), kind:1, bold:1)
                                }.customizationID("Date").alignment(.center)
                            }.onChange(of:srts) { olds, vals in
                                nobj.glob().withLock {
                                    let tmps = "\(vals[0].keyPath):\(vals[0].order)"
                                    if (pidx < 0) {
                                        srts = [vals[0]]
                                        baup.sort(using:srts)
                                        if (srch == "") { tabl = baup }
                                        nobj.sync(inpt:baup)
                                        srtz = tmps
                                    } else {
                                        if ((-1 < pidx) && (pidx < plst.count)) {
                                            plst[pidx][4] = tmps
                                        }
                                    }
                                }
                            }.onChange(of:sels) { olds, vals in
                                nobj.glob().withLock {
                                    if (xfru == nil) {
                                        if ((sell == nil) || (vals.count == 1)) {
                                            sell = vals.first
                                        }
                                        if (sell != nil) {
                                            if ((sels.count > 1) || (!(sels.contains(sell!)))) {
                                                sels.removeAll()
                                            }
                                            sels.insert(sell!)
                                        }
                                    }
                                    nobj.xfer(inpt:sell)
                                }
                            }.onChange(of:xfru) { olds, vals in
                                nobj.glob().withLock {
                                    if (xfru != nil) {
                                        withAnimation {
                                            proxy.scrollTo(xfru!, anchor:.leading)
                                        }
                                        if (xfrs != nil) {
                                            sels.removeAll()
                                            sels.insert(xfrs!)
                                            sell = xfrs!
                                        }
                                        xfrs = nil
                                        xfru = nil
                                    }
                                    nobj.xfer(inpt:sell)
                                }
                            }.onChange(of:relo) { olds, vals in
                                if (relo[1] != relo[0]) {
                                    relo[1] = relo[0]
                                }
                            }.focusable().focused($isfo)
                            .alternatingRowBackgrounds(.disabled)
                            .scrollContentBackground(.hidden)
                            .background(colr(k:"w"))
                            .cornerRadius(7.0)
                            .opacity(0.99)
                            .contextMenu(forSelectionType:mdat.ID.self) { item in
                                /* no-op */
                            } primaryAction: { item in
                                var iidx = 0
                                for trak in baup {
                                    if (item.contains(trak.id)) {
                                        nobj.halt(high:0)
                                        nobj.indx = iidx
                                        bply()
                                    }
                                    iidx = (iidx + 1)
                                }
                            }.onKeyPress(action:{ pres in
                                keyp(pres:pres)
                                return .handled
                            })
                        }
                    }.padding(EdgeInsets(top:-7.9, leading:11.0, bottom:11.0, trailing:11.0))
                        .zIndex(1.0)
                        .overlay(panv())
                        .overlay(pref())
                }.frame(maxWidth:.infinity, maxHeight:.infinity)
                HStack {
                    HStack {
                        HStack {
                            Spacer()
                            let stts = tabl.count.formatted().replacingOccurrences(of:",", with:",")
                            let strv = String(format:"%@  Tracks", stts)
                            txtv(strs:strv, size:15.0, colr:colr(k:"t"), kind:3, bold:0)
                        }.frame(maxWidth:.infinity).offset(y:0.99)
                        HStack {
                            /*Rectangle().frame(width:1.0, height:1.0).foregroundColor(noco())
                             .overlay(RoundedRectangle(cornerRadius:1.0).frame(width:1.9, height:19.0).foregroundColor(colr(k:"t"))*/
                            if let imgo = imgs() {
                                Rectangle().frame(width:1.0, height:1.0).foregroundColor(noco()).padding(EdgeInsets(top:0.0, leading:19.0, bottom:0.0, trailing:19.0)).overlay(
                                    imgo.resizable().frame(width:45.0, height:45.0).opacity(0.75)
                                        .rotationEffect(.degrees(rota)).onChange(of:rotf) {
                                            if (rotf != 0) {
                                                withAnimation(.linear(duration:1).speed(0.15).repeatForever(autoreverses:false)) {
                                                    rota = 360.0
                                                }
                                            } else {
                                                withAnimation(.linear(duration:0)) {
                                                    rota = 0.0
                                                }
                                            }
                                        })
                            }
                        }.padding(EdgeInsets(top:0.0, leading:11.0, bottom:0.0, trailing:11.0)).offset(y:-0.69)
                        HStack {
                            let strv = String(format:"TurnTable  %@", String().version())
                            txtv(strs:strv, size:15.0, colr:colr(k:"t"), kind:3, bold:0)
                            Spacer()
                        }.frame(maxWidth:.infinity).offset(y:0.99)
                    }.offset(x:-7.99, y:-7.99)
                    HStack {
                        Rectangle().frame(width:1.0, height:37.99).foregroundColor(noco()).overlay(ProgressView().scaleEffect(x:0.69, y:0.69, anchor:.center).offset(x:-25.99, y:-7.99))
                    }.opacity(opap)
                }.onHover { over in
                    let iidx = idxs[2]
                    shwp = false
                    clrs[iidx][2] = (clrs[iidx][0] + clrs[iidx][5])
                }
            }.background(bgfu(k:1))
        }.background(bgfu(k:0))
        .onAppear {
            print(Date(),"DEBUG","VIEW","init")
            let _ = main()
        }
    }

    func bgfu(k:Int) -> AnyShapeStyle {
        let iidx = Int(wini[1])
        let noop = Color.clear
        let back = colr(k:"r")
        if (wini[0] <= 60.0) { wini[0] = 97.0 }
        if (k == 0) {
            if (iidx > 0) { return AnyShapeStyle(back.opacity(0.55)) }
            else { return AnyShapeStyle(noop) }
        } else {
            if let blur = winl[iidx] as? Material {
                return AnyShapeStyle(blur.opacity(wini[0]/100))
            }
            return AnyShapeStyle(winc)
        }
    }

    func colr(k:String) -> Color {
        var offs = 0.0
        if (wini[0] <= 60.0) { wini[0] = 97.0 }
        if ((k.count > 1) && k.hasSuffix("h")) { offs = wini[2] }
        var acol = Color.init(red:0.17+offs, green:0.17+offs, blue:0.17+offs, opacity:wini[0]/100)
        var bcol = Color.init(red:0.13+offs, green:0.55+offs, blue:0.87+offs, opacity:0.95)
        var tcol = Color.init(red:0.91+offs, green:0.87+offs, blue:0.71+offs, opacity:0.95)
        var wcol = Color.init(red:0.13+offs, green:0.13+offs, blue:0.13+offs, opacity:0.53)
        var scol = Color.init(red:0.17+offs, green:0.17+offs, blue:0.17+offs, opacity:0.97)
        var rcol = Color.init(red:0.35+offs, green:0.35+offs, blue:0.35+offs, opacity:0.99)
        var gcol = tcol.opacity(0.75)
        var lcol = tcol.opacity(0.79)
        var zcol = tcol.opacity(0.09)
        if (cbno[0] != 0.00) {
            let nsco = NSColor(cbco)
            bcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (chno[0] != 0.00) {
            let nsco = NSColor(chco)
            gcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (ctno[0] != 0.00) {
            let nsco = NSColor(ctco)
            tcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
            lcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent*0.79)
        }
        if (cuno[0] != 0.00) {
            let nsco = NSColor(cuco)
            zcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (cvno[0] != 0.00) {
            let nsco = NSColor(cvco)
            acol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:wini[0]/100)
            scol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (clno[0] != 0.00) {
            let nsco = NSColor(clco)
            wcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (crno[0] != 0.00) {
            let nsco = NSColor(crco)
            rcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if ((k == "a") || (k == "ah")) { return acol }
        if ((k == "b") || (k == "bh")) { return bcol }
        if ((k == "t") || (k == "th")) { return tcol }
        if ((k == "l") || (k == "lh")) { return lcol }
        if ((k == "z") || (k == "zh")) { return zcol }
        if ((k == "w") || (k == "wh")) { return wcol }
        if ((k == "s") || (k == "sh")) { return scol }
        if ((k == "g") || (k == "gh")) { return gcol }
        if ((k == "r") || (k == "rh")) { return rcol }
        let aclr = Color.init(red:0.71+offs, green:0.49+offs, blue:0.93+offs, opacity:0.97)
        let bclr = Color.init(red:0.69+offs, green:0.55+offs, blue:0.45+offs, opacity:0.97)
        let gclr = Color.init(red:0.59+offs, green:0.91+offs, blue:0.57+offs, opacity:0.97)
        let oclr = Color.init(red:0.99+offs, green:0.69+offs, blue:0.15+offs, opacity:0.97)
        if ((k == "fa") || (k == "fah")) { return aclr }
        if ((k == "fb") || (k == "fbh")) { return bclr }
        if ((k == "fg") || (k == "fgh")) { return gclr }
        if ((k == "fo") || (k == "foh")) { return oclr }
        return noco()
    }

    func main() {
        nobj.main(objc:self)
        isfo = true
        shuf[1] = false
        cbco = Color(red:cbno[1], green:cbno[2], blue:cbno[3], opacity:cbno[0])
        chco = Color(red:chno[1], green:chno[2], blue:chno[3], opacity:chno[0])
        ctco = Color(red:ctno[1], green:ctno[2], blue:ctno[3], opacity:ctno[0])
        cuco = Color(red:cuno[1], green:cuno[2], blue:cuno[3], opacity:cuno[0])
        cvco = Color(red:cvno[1], green:cvno[2], blue:cvno[3], opacity:cvno[0])
        clco = Color(red:clno[1], green:clno[2], blue:clno[3], opacity:clno[0])
        crco = Color(red:crno[1], green:crno[2], blue:crno[3], opacity:crno[0])
        winc = colr(k:"a")
        wins = 1
    }

    func form(inpt:Int64) -> String {
        let mins = (inpt / 60)
        let secs = (inpt % 60)
        return String(format:"%02d:%02d", mins, secs)
    }

    func gets(kind:Int) -> String {
        nobj.glob().withLock {
            let hobj = nobj.geth()
            if (hobj != nil) {
                if (kind == 0) { return String(format:"%@", hobj!.song) }
                if (kind == 1) { return String(format:"%@ [%@]", hobj!.band, hobj!.genr) }
            } else {
                if (tabl.count < 1) {
                    if (kind == 0) { return "Loading Tracks" }
                    if (kind == 1) { return "Please Standby" }
                } else {
                    if (kind == 0) { return "Tracks Loaded" }
                    if (kind == 1) { return tabl.count.formatted() }
                }
            }
            return " "
        }
    }

    func symb(r:Int) {
        var iidx = 0
        let idxl = [0, 5, 7]
        let retl = ["play.circle", "pause.circle"]
        if (r == 1) {
            iidx = 1
        }
        mode = retl[iidx]
        for idxi in idxl {
            let jidx = idxs[idxi]
            clrs[jidx][2] = (clrs[jidx][iidx] + clrs[jidx][5])
        }
        imgl = 0
    }

    func play(objc:mdat, over:Int) -> Int {
        let chks = nobj.gets()
        var r = 0
        if ((chks != 1) || (over == 1)) {
            if (nobj.pobj == nil) {
                r = nobj.play(mobj:objc, over:1)
                print(Date(),"DEBUG","play",objc,over,r)
            } else {
                r = nobj.play(mobj:nil, over:1)
                print(Date(),"DEBUG","resu",objc,over,r)
            }
        } else {
            nobj.stop()
            r = 0
            print(Date(),"DEBUG","paus",objc,over,r)
        }
        symb(r:r)
        return 0
   }

    func more() {
        let r = nobj.next(iidx:1, over:0)
        symb(r:r)
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.95) { relo[0] = Int.random(in:1..<1000) }
    }

    func prev() {
        var i = -1
        let l = time[0].components(separatedBy:":")
        if (l.count > 1) {
            let n = Int(l[1])
            if ((n != nil) && (n! >= 5)) { i = 0 }
        }
        let r = nobj.next(iidx:i, over:0)
        symb(r:r)
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.95) { relo[0] = Int.random(in:1..<1000) }
    }

    func bply() {
        if (tabl.count > 0) {
            var iidx = 0
            let hobj = nobj.geth()
            if (hobj != nil) { iidx = nobj.indx }
            let _ = play(objc:baup[iidx], over:0)
        }
    }

    func star() {
        nobj.glob().withLock {
            let hobj = nobj.geth()
            if (hobj != nil) {
                xfrs = hobj!.id
                xfru = hobj!.id
                sels.insert(UUID())
            }
        }
    }

    func fndr() {
        if (!sels.isEmpty) {
            for item in tabl {
                if (sels.contains(item.id)) {
                    let urlp = URL(fileURLWithPath:item.path)
                    NSWorkspace.shared.activateFileViewerSelecting([urlp])
                }
            }
        }
    }

    func filt() {
        let iidx = idxs[3]
        let nows = Int(Date().timeIntervalSince1970)
        if (srch == "") {
            clrs[iidx][2] = clrs[iidx][0]
            usee(mode:1)
        } else {
            clrs[iidx][2] = clrs[iidx][1]
        }
        if ((nows - last) <= 1) {
            DispatchQueue.main.asyncAfter(deadline:.now() + 0.50) { filt() }
        } else if (baup.count > 0) {
            if (srch != "") {
                do {
                    let regx = try Regex("^.*"+srch+".*$").ignoresCase()
                    var temp = [] as [mdat]
                    for item in baup {
                        if let _ = item.hash.wholeMatch(of:regx) {
                            temp.append(item)
                        }
                    }
                    if ((-1 < pidx) && (pidx < plst.count)) {
                        let gsrt = nobj.gens(inpt:plst[pidx][2])
                        temp.sort(using:gsrt)
                    }
                    nobj.glob().withLock {
                        tabl = temp
                    }
                } catch {
                    /* no-op */
                }
            } else {
                nobj.glob().withLock {
                    tabl = baup
                }
                var i = 0
                while (i < bldr.count) {
                    while (bldr[i].count > 1) {
                        bldr[i].removeLast()
                    }
                    i = (i + 1)
                }
            }
        }
    }

    func funp(iidx:Int) -> String {
        var jidx = 0
        var kind = "plus.circle"
        if (shwp == true) {
            jidx = 1
            kind = "minus.circle"
        }
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.0) {
            clrs[iidx][4] = "*"
            clrs[iidx][2] = (clrs[iidx][jidx] + clrs[iidx][5])
        }
        return kind
    }

    func clkp() {
        shws = false
        if (shwp == false) { shwp = true }
        else { shwp = false }
    }

    func panv() -> AnyView {
        var vobj = AnyView(EmptyView())
        if (shwp == true) {
            //let side = [0.0, 0.0]
            let side = [65.0, 97.0]
            let wide = 256.0
            let bpad = 60.0
            let rads = 17.0
            let zclr = "g"
            vobj = AnyView(
                ZStack {
                    HStack {
                        VStack {
                            HStack {
                                Spacer()
                                ZStack {
                                    VStack {
                                        RoundedRectangle(cornerRadius:rads).inset(by:-1.0)
                                            .stroke(colr(k:zclr), lineWidth:2.33)
                                            .overlay(
                                                HStack {
                                                    VStack {
                                                        HStack {
                                                            let iidx = idxs[4]
                                                            Spacer()
                                                            TextField("Playlist", text:$name)
                                                                .onChange(of:name) { olds, vals in
                                                                    if (name == "") {
                                                                        clrs[iidx][2] = clrs[iidx][0]
                                                                        usee(mode:9)
                                                                    } else {
                                                                        clrs[iidx][2] = clrs[iidx][1]
                                                                    }
                                                                }
                                                                .frame(width:128.0)
                                                                .showClearButton($name)
                                                                .foregroundColor(colr(k:"t"))
                                                                .disableAutocorrection(true)
                                                                .textFieldStyle(.plain)
                                                                .font(Font.custom("Menlo", size:13.0).weight(.bold))
                                                                .padding(EdgeInsets(top:1.5, leading:12.0, bottom:1.5, trailing:24.0))
                                                                .overlay(RoundedRectangle(cornerRadius:9.0).inset(by:-3.5).stroke(colr(k:clrs[iidx][2]), lineWidth:3.0))
                                                                .offset(x:3.0, y:0.5)
                                                            Rectangle().foregroundColor(noco()).frame(width:1.0, height:1.0)
                                                            butv(kind:"plus.circle", size:24.0, extr:[0.0, 0.0], iidx:11, clst:["b", "g", "b", "!"], meth:-1, pram:-1, actn:padd)
                                                            Rectangle().foregroundColor(noco()).frame(width:5.9, height:1.0)
                                                        }
                                                        HStack {
                                                            butv(kind:"a.circle", size:20.0, extr:[0.0, 0.0], iidx:16, clst:["fa", "g", "fa", "!"], meth:0, pram:0, actn:nill)
                                                            butv(kind:"b.circle", size:20.0, extr:[0.0, 0.0], iidx:17, clst:["fb", "g", "fb", "!"], meth:0, pram:1, actn:nill)
                                                            butv(kind:"g.circle", size:20.0, extr:[0.0, 0.0], iidx:18, clst:["fg", "g", "fg", "!"], meth:0, pram:2, actn:nill)
                                                            butv(kind:"y.circle", size:20.0, extr:[0.0, 0.0], iidx:19, clst:["fo", "g", "fo", "!"], meth:0, pram:3, actn:nill)
                                                        }.padding(EdgeInsets(top:4.0, leading:0.0, bottom:16.0, trailing:0.0))
                                                        List {
                                                            ForEach(0..<plst.count, id:\.self) { i in
                                                                HStack {
                                                                    txtv(strs:plst[i][0], size:15.0, colr:colr(k:"t"), kind:0, bold:0).padding(.leading, 8.0)
                                                                    Spacer()
                                                                    butv(kind:"pencil.circle", size:20.0, extr:[0.0, 0.0], iidx:100+i, clst:["b", "g", "b", "!"], meth:1, pram:i, actn:nill)
                                                                    butv(kind:"multiply.circle", size:20.0, extr:[0.0, 0.0], iidx:200+i, clst:["b", "g", "b", "!"], meth:2, pram:i, actn:nill)
                                                                }.padding(EdgeInsets(top:4.0, leading:0.0, bottom:4.0, trailing:8.0)).cornerRadius(15.0).background(pcol(iidx:i)).listRowSeparator(.hidden)
                                                                    .contentShape(Rectangle()).onTapGesture {
                                                                        psel(iidx:i)
                                                                    }
                                                            }
                                                            Spacer()
                                                        }.scrollIndicators(.never).scrollContentBackground(.hidden).background(noco()).frame(maxHeight:.infinity)
                                                            .padding(EdgeInsets(top:0.0, leading:0.0, bottom:8.0, trailing:-9.0))
                                                    }
                                                }.frame(maxWidth:.infinity, maxHeight:.infinity).padding(.top, 12.0).padding(.trailing, side[0]).background(colr(k:"s")).cornerRadius(rads)
                                            )
                                        Rectangle().foregroundColor(noco()).frame(width:1.0, height:bpad)
                                    }
                                }.frame(width:wide+side[0]).offset(x:-45.0+side[1], y:35.0)
                            }
                            Spacer()
                        }
                        if (side[0] != 0.0) {
                            ZStack { Rectangle().frame(width:1.0).foregroundColor(noco()).overlay(
                                RoundedRectangle(cornerRadius:9.0).frame(width:45.0).frame(maxHeight:.infinity)
                                    .padding(EdgeInsets(top:25.0, leading:0.0, bottom:25.0, trailing:0.0)).offset(y:-5.0)
                                    .foregroundColor(colr(k:"s"))
                            ) }.zIndex(33.0)
                        }
                    }
                }.zIndex(11.0)
            )
        }
        return vobj
    }

    func funs(iidx:Int) -> String {
        let jidx = (shws == false) ? 0 : 1
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.0) {
            clrs[iidx][4] = "*"
            clrs[iidx][2] = (clrs[iidx][jidx] + clrs[iidx][5])
        }
        return "gearshape.circle"
    }

    func clks() {
        shwp = false
        if (shws == false) { shws = true }
        else { shws = false }
    }

    func pref() -> AnyView {
        var vobj = AnyView(EmptyView())
        if (shws == true) {
            let side = [0.0, 0.0]
            let bpad = 60.0
            let wpad = 75.0
            let rads = 17.0
            let zclr = "g"
            vobj = AnyView(
                ZStack {
                    HStack {
                        VStack {
                            HStack {
                                Spacer()
                                ZStack {
                                    VStack {
                                        RoundedRectangle(cornerRadius:rads).inset(by:-1.0)
                                            .stroke(colr(k:zclr), lineWidth:2.33)
                                            .overlay(
                                                VStack {
                                                    VStack {
                                                        HStack {
                                                            Spacer()
                                                            txtv(strs:"Settings", size:19.0, colr:colr(k:"t"), kind:0, bold:1)
                                                            Spacer()
                                                        }
                                                        Text(" ")
                                                        Text(" ")
                                                        HStack {
                                                            txtv(strs:"Colors", size:15.0, colr:colr(k:"t"), kind:0, bold:1)
                                                            Text(" ")
                                                            butv(kind:"multiply.circle", size:20.0, extr:[0.0, 0.0], iidx:91, clst:["b", "g", "b", "!"], meth:-1, pram:-1, actn:nilz)
                                                            Text(" ")
                                                            Text(" ")
                                                            ColorPicker("Base", selection:$cbco).onChange(of:cbco) {
                                                                let temp = NSColor(cbco)
                                                                cbno = [temp.alphaComponent, temp.redComponent, temp.greenComponent, temp.blueComponent, 0.0]
                                                                refz()
                                                            }
                                                            Text(" ")
                                                            ColorPicker("High", selection:$chco).onChange(of:chco) {
                                                                let temp = NSColor(chco)
                                                                chno = [temp.alphaComponent, temp.redComponent, temp.greenComponent, temp.blueComponent, 0.0]
                                                                refz()
                                                            }
                                                            Text(" ")
                                                            ColorPicker("Text", selection:$ctco).onChange(of:ctco) {
                                                                let temp = NSColor(ctco)
                                                                ctno = [temp.alphaComponent, temp.redComponent, temp.greenComponent, temp.blueComponent, 0.0]
                                                                refz()
                                                            }
                                                            Text(" ")
                                                            ColorPicker("Tint", selection:$cuco).onChange(of:cuco) {
                                                                let temp = NSColor(cuco)
                                                                cuno = [temp.alphaComponent, temp.redComponent, temp.greenComponent, temp.blueComponent, 0.0]
                                                                refz()
                                                            }
                                                            Text(" ")
                                                            ColorPicker("View", selection:$cvco).onChange(of:cvco) {
                                                                let temp = NSColor(cvco)
                                                                cvno = [temp.alphaComponent, temp.redComponent, temp.greenComponent, temp.blueComponent, 0.0]
                                                                refz()
                                                            }
                                                            Text(" ")
                                                            ColorPicker("List", selection:$clco).onChange(of:clco) {
                                                                let temp = NSColor(clco)
                                                                clno = [temp.alphaComponent, temp.redComponent, temp.greenComponent, temp.blueComponent, 0.0]
                                                                refz()
                                                            }
                                                            Text(" ")
                                                            ColorPicker("Blur", selection:$crco).onChange(of:crco) {
                                                                let temp = NSColor(crco)
                                                                crno = [temp.alphaComponent, temp.redComponent, temp.greenComponent, temp.blueComponent, 0.0]
                                                                refz()
                                                            }
                                                            Spacer()
                                                        }
                                                        Text(" ")
                                                        HStack {
                                                            var nice = round(wini[2] * 100)
                                                            txtv(strs:"Window", size:15.0, colr:colr(k:"t"), kind:0, bold:1)
                                                            Text(" ")
                                                            butv(kind:"multiply.circle", size:20.0, extr:[0.0, 0.0], iidx:90, clst:["b", "g", "b", "!"], meth:-1, pram:-1, actn:zilw)
                                                            Text(" ")
                                                            Text(" ")
                                                            txtv(strs:"Opacity", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                            Slider(value:$wini[0], in:69...99, step:1).frame(width:128.0).onChange(of:wini[0]) {
                                                                winc = colr(k:"a")
                                                                wins = 1
                                                            }
                                                            txtv(strs:"\(Int(wini[0]))", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                            Text(" ")
                                                            Text(" ")
                                                            txtv(strs:"Blur", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                            Slider(value:$wini[1], in:0...5, step:1).frame(width:128.0).onChange(of:wini[1]) {
                                                                wins = 2
                                                            }
                                                            Text(" ")
                                                            Text(" ")
                                                            txtv(strs:"Hover", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                            Slider(value:$wini[2], in:-0.19...0.19, step:0.001).frame(width:128.0).onChange(of:wini[2]) {
                                                                nice = round(wini[2] * 100)
                                                                wini[2] = (Double(nice) / 100)
                                                            }
                                                            let outs = String(format:"%@0.%02d", (nice < 0.0) ? "-" : "+", Int(abs(nice)))
                                                            txtv(strs:"\(outs)", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                            Spacer()
                                                        }
                                                        Spacer()
                                                    }.padding(.leading, 16.0)
                                                }.frame(maxWidth:.infinity, maxHeight:.infinity).padding(.top, 12.0).padding(.trailing, side[0]).background(colr(k:"s")).cornerRadius(rads)
                                            )
                                        Rectangle().foregroundColor(noco()).frame(width:1.0, height:bpad)
                                    }
                                }.padding(.leading, 89.0+wpad).offset(x:-45.0+side[1], y:35.0)
                            }
                            Spacer()
                        }
                    }
                }.zIndex(11.0)
            )
        }
        return vobj
    }

    func colv() -> AnyView {
        var vobj = AnyView(EmptyView())
        if (tsho == "on") {
            vobj = AnyView(HStack {
                ZStack {
                    HStack {
                        Table(coad, selection:$coas) {
                            TableColumn("Artist") { temp in
                                txtv(strs:temp.band, size:13.0, colr:colr(k:"l"), kind:0, bold:0)
                            }
                        }
                        .alternatingRowBackgrounds(.disabled)
                        .scrollContentBackground(.hidden)
                        .background(colr(k:"w"))
                        .cornerRadius(5.0)
                        .opacity(0.99)
                        .onChange(of:coas) { olds, vals in
                                var flag = 0
                                var objc: mdat?
                                var temp = [] as [mdat]
                                if (vals.count > 0) {
                                    for item in coad {
                                        if (item.id == vals.first) {
                                            if (item.band != "---") {
                                                for elem in cobd {
                                                    if (elem.band == item.band) {
                                                        temp.append(elem)
                                                    }
                                                }
                                                flag = 1
                                            } else {
                                                flag = 2
                                            }
                                            objc = item
                                        }
                                    }
                                }
                                if (flag == 1) { cobt = temp ; cobt.insert(contentsOf:[cobd[0]], at:0) }
                                else { cobt = cobd }
                                if (objc != nil) { help(kind:0, colv:objc!.band) }
                            }
                        Table(cobt, selection:$cobs) {
                            TableColumn("Album") { temp in
                                txtv(strs:temp.albm, size:13.0, colr:colr(k:"l"), kind:0, bold:0)
                            }
                        }
                        .alternatingRowBackgrounds(.disabled)
                        .scrollContentBackground(.hidden)
                        .background(colr(k:"w"))
                        .cornerRadius(5.0)
                        .opacity(0.99)
                        .padding(EdgeInsets(top:0.0, leading:-7.0, bottom:0.0, trailing:-7.0))
                        .onChange(of:cobs) { olds, vals in
                                var flag = 0
                                var objc: mdat?
                                var uniq = [] as [String]
                                var temp = [] as [mdat]
                                if (vals.count > 0) {
                                    for item in cobt {
                                        if (item.id == vals.first) {
                                            if (item.albm != "---") {
                                                for elem in baup {
                                                    if ((elem.band == item.band) && (elem.albm == item.albm)) {
                                                        if (!(uniq.contains(elem.genr))) {
                                                            temp.append(elem)
                                                            uniq.append(elem.genr)
                                                        }
                                                    }
                                                }
                                                flag = 1
                                            } else {
                                                if (cobt.count > 1) {
                                                    for elem in baup {
                                                        if (elem.band == cobt[1].band) {
                                                            if (!(uniq.contains(elem.genr))) {
                                                                temp.append(elem)
                                                                uniq.append(elem.genr)
                                                            }
                                                        }
                                                    }
                                                }
                                                flag = 1
                                            }
                                            objc = item
                                        }
                                    }
                                }
                                if (flag == 1) { coct = temp ; coct.insert(contentsOf:[cocd[0]], at:0) }
                                else { coct = cocd }
                                if (objc != nil) { help(kind:1, colv:objc!.albm) }
                            }
                        Table(coct, selection:$cocs) {
                            TableColumn("Genre") { temp in
                                txtv(strs:temp.genr, size:13.0, colr:colr(k:"l"), kind:0, bold:0)
                            }
                        }
                        .alternatingRowBackgrounds(.disabled)
                        .scrollContentBackground(.hidden)
                        .background(colr(k:"w"))
                        .cornerRadius(5.0)
                        .opacity(0.99)
                        .onChange(of:cocs) { olds, vals in
                                var objc: mdat?
                                if (vals.count > 0) {
                                    for item in coct {
                                        if (item.id == vals.first) {
                                            objc = item
                                        }
                                    }
                                }
                                if (objc != nil) { help(kind:2, colv:objc!.genr) }
                            }
                    }.frame(height:175.0).padding(EdgeInsets(top:-7.9, leading:11.0, bottom:7.9, trailing:11.0))
                }
            })
        }
        return vobj
    }

    func padd() {
        if ((srch != "") && (name != "")) {
            plst.append([name, srch, "f", "name"])
        }
    }

    func pdel(iidx:Int) {
        if ((-1 < iidx) && (iidx < plst.count)) {
            plst.remove(at:iidx)
            usee(mode:9)
        }
    }

    func pedt(iidx:Int) {
        if ((srch != "") && (name != "")) {
            if ((-1 < iidx) && (iidx < plst.count)) {
                if (plst[iidx].count < 3) { plst[iidx].append("f") }
                if (plst[iidx].count < 4) { plst[iidx].append("name") }
                plst[iidx][0] = name
                plst[iidx][1] = srch
            }
        }
    }

    func psel(iidx:Int) {
        if ((-1 < iidx) && (iidx < plst.count)) {
            if (plst[iidx].count < 3) { plst[iidx].append("f") }
            if (plst[iidx].count < 4) { plst[iidx].append("name") }
            print("DEBUG","PLST",plst[iidx])
            pidx = iidx
            name = plst[pidx][0]
            srch = plst[pidx][1]
            if (plst[pidx][2] == "f") { shuf[1] = false }
            else { shuf[1] = true }
            let _ = shfu()
        }
    }

    func pcol(iidx:Int) -> Color {
        if ((srch != "") && (name != "")) {
            if (iidx == pidx) { return colr(k:"z") }
        }
        return noco()
    }

    func help(kind:Int, colv:String) {
        let good = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- "
        if (colv != "") {
            var limi = 1
            if (colv != "---") {
                if (bldr[kind].count < 2) {
                    bldr[kind].append(colv)
                }
                bldr[kind][1] = colv
                limi = 2
            }
            while (bldr[kind].count > limi) { bldr[kind].removeLast() }
            sell = nil
            sels.removeAll()
        } else if (sell != nil) {
            for item in baup {
                if (item.id == sell!) {
                    let valu = [item.band, item.albm, item.genr, item.year]
                    if ((valu[kind] != "") && (valu[kind] != "---")) {
                        if (!(bldr[kind].contains(valu[kind]))) {
                            bldr[kind].append(valu[kind])
                        }
                    }
                }
            }
        }
        var regx = ""
        for item in bldr {
            var line = ""
            var indx = 0
            for valu in item {
                if (indx > 0) {
                    if (line != "") { line = (line + "|") }
                    let sane = String(valu.map { good.contains($0) ? $0 : "." })
                    line = (line + sane)
                }
                indx += 1
            }
            if (line != "") {
                line = (item[0] + ":" + "(" + line + ")")
                if (regx != "") { regx = (regx + ".*") }
                regx = (regx + line)
            }
        }
        srch = regx
    }

    func shot() {
        if (tsho == "no") { tsho = "on" }
        else { tsho = "no" }
    }

    func usee(mode:Int) {
        isfo = true
        sell = nil
        sels.removeAll()
        coas.removeAll()
        cobs.removeAll()
        cocs.removeAll()
        srch = ""
        name = ""
        if (mode == 9) {
            shuf[1] = false
            let _ = shfu()
            if (pidx > -1) {
                let gsrt = nobj.gens(inpt:srtz)
                nobj.glob().withLock {
                    tabl.sort(using:gsrt)
                }
                pidx = -1
            }
        }
    }

    func shfu() -> Bool {
        let iidx = idxs[1]
        if ((shuf[0] == false) && (shuf[1] == false)) {
            clrs[iidx][2] = (clrs[iidx][0] + clrs[iidx][5])
            return false
        } else {
            clrs[iidx][2] = (clrs[iidx][1] + clrs[iidx][5])
            return true
        }
    }

    func shfs() {
        var iidx = 0
        if (pidx > -1) {
            if ((-1 < pidx) && (pidx < plst.count)) {
                if (plst[pidx][2] == "f") {
                    shuf[1] = false
                    plst[pidx][2] = "t"
                } else {
                    shuf[1] = true
                    plst[pidx][2] = "f"
                }
            }
            iidx = 1
        }
        if (shuf[iidx] == false) { shuf[iidx] = true }
        else { shuf[iidx] = false }
        let _ = shfu()
    }

    func refz() {
        sldv = [colr(k:"b"), colr(k:"b"), colr(k:"bh"), colr(k:"bh")]
        sldr = [colr(k:"t"), colr(k:"b"), colr(k:"th"), colr(k:"bh")]
        winc = colr(k:"a")
        wins = 3
        imgl = 0
    }

    func nilz() {
        cbno = [0.0, 0.0, 0.0, 0.0, 0.0]
        cbco = Color.clear
        chno = [0.0, 0.0, 0.0, 0.0, 0.0]
        chco = Color.clear
        ctno = [0.0, 0.0, 0.0, 0.0, 0.0]
        ctco = Color.clear
        cuno = [0.0, 0.0, 0.0, 0.0, 0.0]
        cuco = Color.clear
        cvno = [0.0, 0.0, 0.0, 0.0, 0.0]
        cvco = Color.clear
        clno = [0.0, 0.0, 0.0, 0.0, 0.0]
        clco = Color.clear
        crno = [0.0, 0.0, 0.0, 0.0, 0.0]
        crco = Color.clear
    }

    func zilw() {
        wini[0] = 0.0
        wini[1] = 0.0
        wini[2] = 0.19
    }

    func minv() {
        let iidx = idxs[6]
        if (volu[2] == 1.00) {
            mute = true
            volu[2] = 0.00
            nobj.plyr.volume = 0.00
            clrs[iidx][2] = (clrs[iidx][1] + clrs[iidx][5])
        } else {
            mute = false
            volu[1] = 0.00
            volu[0] = 0.00
            nobj.plyr.volume = 0.00
            clrs[iidx][2] = (clrs[iidx][0] + clrs[iidx][5])
        }
    }

    func maxv() {
        let iidx = idxs[6]
        if (volu[2] == 1.00) {
            volu[1] = 1.00
            volu[0] = 1.00
        } else if ((volu[1] == 0.00) && (volu[0] == 0.00)) {
            volu[1] = 1.00
            volu[0] = 1.00
        }
        mute = true
        volu[2] = 1.00
        nobj.plyr.volume = Float(volu[1])
        clrs[iidx][2] = (clrs[iidx][0] + clrs[iidx][5])
    }

    func nill() {
        print(Date(),"DEBUG","noop")
    }

    func noco() -> Color {
        return Color.init(red:0.0, green:0.0, blue:0.0, opacity:0.0)
    }

    func butv(kind:String, size:CGFloat, extr:[CGFloat], iidx:Int, clst:[String], meth:Int, pram:Int, actn:@escaping () -> Void) -> some View {
        let objc = Image(systemName:kind).resizable().scaledToFit().frame(width:size, height:size).foregroundColor(colr(k:clrs[iidx][2])).onAppear {
            clrs[iidx] = [clst[0], clst[1], clst[2], clst[3], "", ""]
        }.onTapGesture {
            let fstr = clrs[iidx][2].fstrs(char:"h")
            let jidx = (fstr == clrs[iidx][0]) ? 1 : 0
            clrs[iidx][4] = clrs[iidx][jidx]
            if (clrs[iidx][3] != "~") {
                clrs[iidx][2] = (clrs[iidx][jidx] + clrs[iidx][5])
            }
            if (clrs[iidx][3] == "!") {
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.19) { clrs[iidx][2] = (clrs[iidx][0] + clrs[iidx][5]) }
            }
            if (meth == -1) { actn() }
            if (meth == 0) { help(kind:pram, colv:"") }
            if (meth == 1) { pedt(iidx:pram) }
            if (meth == 2) { pdel(iidx:pram) }
            if (meth == 3) { usee(mode:pram) }
            isfo = true
        }.onContinuousHover { phase in
            let fstr = clrs[iidx][2].fstrs(char:"h")
            switch phase {
            case .active:
                if (clrs[iidx][4] == "") {
                    if (clrs[iidx][2] != (fstr + "h")) { clrs[iidx][2] = (fstr + "h") }
                }
                if (clrs[iidx][5] == "") {
                    clrs[iidx][5] = "h"
                }
            case .ended:
                if (clrs[iidx][2] != (fstr + "")) {
                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.09) { clrs[iidx][2] = (clrs[iidx][2].fstrs(char:"h") + "") }
                }
                clrs[iidx][5] = ""
                clrs[iidx][4] = ""
            }
        }
        return Rectangle()
            .fill(noco()).frame(width:size+extr[0], height:size+extr[1]).overlay(objc)
    }

    func txtv(strs:String, size:CGFloat, colr:Color, kind:Int, bold:Int) -> some View {
        var ssiz = size
        let name = ["Menlo", "Courier New", "Courier", "Copperplate"]
        if (kind == 0) {
            ssiz = (ssiz + 0.0)
        } else if ((kind == 1) || (kind == 2)) {
            ssiz = (ssiz + 2.0)
        } else {
            ssiz = (ssiz + 4.0)
        }
        return Text(strs).font(Font.custom(name[kind], size:ssiz).weight((bold != 1) ? .regular : .bold)).foregroundColor(colr).lineLimit(1).truncationMode(.tail)
    }

    func keyp(pres:KeyPress) {
        let temp = pres.characters.data(using:.utf8)!
        print(Date(),"DEBUG","CHAR",temp.hexs())
        if (temp.count == 1) {
            if (temp[0] == 32) { bply() }
        } else if (temp.count == 3) {
            if ((temp[0] == 239) && (temp[1] == 156)) {
                if (temp[2] == 131) { more() }
                if (temp[2] == 130) { prev() }
            }
        }
    }

    func imgs() -> Image? {
        let iidx = idxs[7]
        let secs = Int(Date().timeIntervalSince1970)
        if ((imgd == nil) || ((secs - imgl) >= 5)) {
            let size = 384.0
            let rest = ((512.0 - size) / 2.0)
            let aimg = NSImage(named:"record.png")
            let bimg = NSImage(named:"music.png")
            bimg?.lockFocus()
            NSColor(colr(k:clrs[iidx][2])).set()
            let imgr = NSRect(origin: NSZeroPoint, size:bimg!.size)
            __NSRectFillUsingOperation(imgr, NSCompositingOperation.sourceAtop)
            bimg?.unlockFocus()
            aimg?.lockFocus()
            bimg?.draw(in:NSRect(x:rest-21.0, y:rest, width:size, height:size), from:NSZeroRect, operation:NSCompositingOperation.sourceOver, fraction:1.0)
            aimg?.unlockFocus()
            DispatchQueue.main.asyncAfter(deadline:.now() + 0.0) {
                imgd = Image(nsImage:aimg!)
                imgl = secs
            }
        }
        return imgd
    }

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
