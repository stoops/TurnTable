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
        let l = ["Blues", "Classic Rock", "Country", "Dance", "Disco", "Funk", "Grunge", "Hip-Hop", "Jazz", "Metal", "New Age", "Oldies", "Other", "Pop", "R&B", "Rap", "Reggae", "Rock", "Techno", "Industrial", "Alternative", "Ska", "Death Metal", "Pranks", "Soundtrack", "Euro-Techno", "Ambient", "Trip-Hop", "Vocal", "Jazz+Funk", "Fusion", "Trance", "Classical", "Instrumental", "Acid", "House", "Game", "Sound Clip", "Gospel", "Noise", "AlternRock", "Bass", "Soul", "Punk", "Space", "Meditative", "Instrumental Pop", "Instrumental Rock", "Ethnic", "Gothic", "Darkwave", "Techno-Industrial", "Electronic", "Pop-Folk", "Eurodance", "Dream", "Southern Rock", "Comedy", "Cult", "Gangsta", "Top 40", "Christian Rap", "Pop/Funk", "Jungle", "Native American", "Cabaret", "New Wave", "Psychadelic", "Rave", "Showtunes", "Trailer", "Lo-Fi", "Tribal", "Acid Punk", "Acid Jazz", "Polka", "Retro", "Musical", "Rock & Roll", "Hard Rock", "Folk", "Folk-Rock", "National Folk", "Swing", "Fast Fusion", "Bebob", "Latin", "Revival", "Celtic", "Bluegrass", "Avantgarde", "Gothic Rock", "Progressive Rock", "Psychedelic Rock", "Symphonic Rock", "Slow Rock", "Big Band", "Chorus", "Easy Listening", "Acoustic", "Humour", "Speech", "Chanson", "Opera", "Chamber Music", "Sonata", "Symphony", "Booty Bass", "Primus", "Porn Groove", "Satire", "Slow Jam", "Club", "Tango", "Samba", "Folklore", "Ballad", "Power Ballad", "Rhythmic Soul", "Freestyle", "Duet", "Punk Rock", "Drum Solo", "A cappella", "Euro-House", "Dance Hall"]
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

struct slid: View {
    @Binding var locks: Bool
    @Binding var edits: Bool
    @Binding var value: Double
    var colrs: Color
    var backg: Color

    @State var lastcoord: CGFloat = 0.0

    var body: some View {
        GeometryReader { gr in
            let radial = (gr.size.height * 0.75)
            let radius = (gr.size.height * 0.69)
            let minval = (gr.size.width * 0.010)
            let maxval = (gr.size.width * 0.99) - radial

            ZStack {
                RoundedRectangle(cornerRadius:radius).foregroundColor(backg.opacity(0.33))
                HStack {
                    Circle()
                        .foregroundColor(colrs).brightness(0.15)
                        .frame(width:radial, height:radial)
                        .offset(x:safes(valus:self.value, minms:minval, maxms:maxval, divrs:1.0), y:0.0)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    self.edits = true
                                    if (abs(v.translation.width) < 0.1) {
                                        self.lastcoord = safes(valus:self.value, minms:minval, maxms:maxval, divrs:1.0)
                                    }
                                    let temps = (self.lastcoord + v.translation.width)
                                    self.value = safes(valus:temps, minms:minval, maxms:maxval, divrs:maxval) / maxval
                                }
                                .onEnded() { v in
                                    self.edits = false
                                }
                        )
                    Spacer()
                }
            }
        }
    }

    func safes(valus:Double, minms:Double, maxms:Double, divrs:Double) -> Double {
        if (locks) { return minms }
        return min(maxms, max(minms, valus * (maxms / divrs)))
    }
}

struct mdat: Identifiable {
    let id = UUID()
    let path: String
    let song: String
    let name: String
    let albm: String
    let genr: String
    let tstr: String
    let date: String
    let null: String
    let hash: String
    let time: Int64
}

class note: NotificationCenter, @unchecked Sendable {

    @AppStorage("ClassBook")
    var book: Data?

    var view: ContentView?
    let lock = NSLock()
    var inil = [] as [String]
    var tabp = [] as [mdat]
    var tabt = [] as [mdat]
    var pobj: AVPlayerItem?
    var plyr = AVPlayer()
    var stal: Bool = true
    var outp = ""
    var stat = 0
    var load = 0
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

    func mkda() -> Data {
        return "".data(using:.utf8)!
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

    func mods(path:String, back:String) -> String {
        do {
            let purl = URL(fileURLWithPath:path)
            let attr = try FileManager.default.attributesOfItem(atPath:purl.path)
            let dobj = attr[FileAttributeKey.modificationDate] as? Date
            let form = DateFormatter()
            form.dateFormat = "yyyy/dd/MM HH:mm:ss"
            let temp = form.string(from:dobj!)
            return temp
        } catch {
            return back
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

    func make(path:String, song:String, name:String, albm:String, genr:String, tstr:String, date:String, null:String, time:Int64) -> mdat {
        let hash = "song:\(song), name:\(name), albm:\(albm), genr:\(genr), tstr:\(tstr), date:\(date), path:\(path)"
        return mdat(path:path, song:song, name:name, albm:albm, genr:genr, tstr:tstr, date:date, null:null, hash:hash, time:time)
    }

    func gens(inpt:String) -> [KeyPathComparator<mdat>] {
        let dirs = inpt.contains("reverse") ? SortOrder.reverse : SortOrder.forward
        if (inpt.contains("song")) { return [KeyPathComparator(\mdat.song, order:dirs)] }
        if (inpt.contains("albm")) { return [KeyPathComparator(\mdat.albm, order:dirs)] }
        if (inpt.contains("genr")) { return [KeyPathComparator(\mdat.genr, order:dirs)] }
        if (inpt.contains("tstr")) { return [KeyPathComparator(\mdat.tstr, order:dirs)] }
        if (inpt.contains("date")) { return [KeyPathComparator(\mdat.date, order:dirs)] }
        return [KeyPathComparator(\mdat.name, order:dirs)]
    }

    func loop() {
        let objc = view!
        let prog = \ContentView.prog
        let hold = \ContentView.hold
        let time = \ContentView.time
        let tabl = \ContentView.tabl
        let baup = \ContentView.baup
        let srch = \ContentView.srch
        let srts = \ContentView.srts
        let srtz = \ContentView.srtz
        let show = \ContentView.stat
        let noop = \ContentView.sldr
        let edit = \ContentView.edit
        var csec = Int64(0)
        var cstr = form(inpt:csec)
        var tsec = Int64(0)
        var tstr = form(inpt:tsec)
        var psec = Double(0.0)
        var seek = 0
        while (0 == 0) {
            let secs = Int(Date().timeIntervalSince1970)
            if ((secs - load) >= (15 * 60)) {
                load = secs
                outp = ""
                proc()
            }
            let chks = gets()
            if (chks > 0) { objc[keyPath:noop] = false }
            else { objc[keyPath:noop] = true }
            if ((stat == 1) && (chks < 0)) {
                let _ = next(iidx:1, over:1)
            }
            if ((stat == 1) && (chks == 1)) {
                let cobj = plyr.currentTime()
                csec = divs(a:Int64(cobj.value), b:Int64(cobj.timescale))
                if (objc[keyPath:hold] != nil) { tsec = objc[keyPath:hold]!.time }
                if (tsec < 1) { tsec = 1 }
            }
            if (tsec > 1) {
                if (pobj == nil) { csec = 0 }
                if (objc[keyPath:edit] || (seek != 0)) {
                    seek = 1
                    psec = (Double(objc[keyPath:prog]) * Double(tsec))
                    csec = Int64(psec)
                    cstr = form(inpt:csec)
                    objc[keyPath:time][0] = cstr
                    if (!objc[keyPath:edit]) {
                        if (csec > 0) {
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
            if ((numb > 0) && (numb == numt)) {
                if ((secs - last) >= 3) {
                    lock.withLock {
                        print(Date(),"DEBUG","xfer",numt,numb,nump,numq)
                        let gsrt = gens(inpt:objc[keyPath:srtz])
                        /*objc[keyPath:srts] = gsrt*/
                        tabt.removeAll()
                        tabp.sort(using:gsrt/*objc[keyPath:srts]*/)
                        if (objc[keyPath:baup].count < 1) {
                            objc[keyPath:baup] = tabp
                        }
                        var i = 0
                        for item in tabp {
                            if (i >= objc[keyPath:baup].count) {
                                objc[keyPath:baup].append(item)
                            } else if (item.hash != objc[keyPath:baup][i].hash) {
                                //check if in selection set to restore if so
                                objc[keyPath:baup][i] = item
                            }
                            i = (i + 1)
                        }
                        while (objc[keyPath:baup].count > numb) {
                            objc[keyPath:baup].removeLast()
                        }
                        if (objc[keyPath:srch] == "") {
                            objc[keyPath:tabl] = objc[keyPath:baup]
                        }
                        objc[keyPath:show] = numb.formatted()
                    }
                    last = secs
                }
            }
            print(Date(),"DEBUG","loop",inil,cstr,tstr,psec,stat,chks,indx,load,numt,numb,nump,numq)
            usleep(750000)
        }
    }

    func symb(iidx:Int, syms:String) -> mdat? {
        let objc = view!
        let tabl = \ContentView.tabl
        let baup = \ContentView.baup
        let sels = \ContentView.sels
        let srch = \ContentView.srch
        if (iidx > -1) {
            let mobj = tabp[iidx]
            let temp = make(path:mobj.path, song:mobj.song, name:mobj.name, albm:mobj.albm, genr:mobj.genr, tstr:mobj.tstr, date:mobj.date, null:syms, time:mobj.time)
            tabp[iidx] = temp
            objc[keyPath:baup][iidx] = temp
            if (objc[keyPath:srch] == "") {
                objc[keyPath:tabl][iidx] = temp
            }
            if (syms == "~") {
                objc[keyPath:sels].removeAll()
                objc[keyPath:sels].insert(temp.id)
            }
            return temp
        }
        return nil
    }

    func play(mobj:mdat?) -> Int {
        let objc = view!
        let baup = \ContentView.baup
        let hold = \ContentView.hold
        let mode = \ContentView.mode
        let mcol = \ContentView.mcol
        if (mobj != nil) {
            var iter = 0
            var iidx = -9
            for item in objc[keyPath:baup] {
                if (item.path == mobj!.path) {
                    iidx = iter
                }
                iter = (iter + 1)
            }
            if (iidx > -1) { indx = iidx }
            if (mods(path:mobj!.path, back:"") == "") { iidx = -8 }
            if (iidx < 0) { return iidx }
            let purl = URL(fileURLWithPath:mobj!.path)
            pobj = AVPlayerItem(url:purl)
            plyr = AVPlayer(playerItem:pobj)
            meta(path:nil, pobj:mobj!)
            plyr.play()
            let temp = symb(iidx:indx, syms:"~")
            objc[keyPath:hold] = temp
            objc[keyPath:mode] = "pause.circle"
            objc[keyPath:mcol] = "t"
            stat = 9
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

    func halt() {
        let _ = symb(iidx:indx, syms:"*")
        stop()
        pobj = nil
        stat = 0
    }

    func next(iidx:Int, over:Int) -> Int {
        let objc = view!
        let baup = \ContentView.baup
        let hold = \ContentView.hold
        let leng = objc[keyPath:baup].count
        let chks = gets()
        halt()
        if (leng < 1) { return -1 }
        indx = (indx + iidx)
        if (indx < 0) { indx = (leng - 1) }
        indx = (indx % leng)
        if ((chks == 1) || (over == 1)) {
            let _ = play(mobj:objc[keyPath:baup][indx])
        } else {
            let temp = symb(iidx:indx, syms:"~")
            objc[keyPath:hold] = temp
            pobj = nil
        }
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
                            tabt.removeAll()
                            let list = outp.components(separatedBy:"\n").filter { !$0.isEmpty }
                            for line in list {
                                meta(path:line, pobj:nil)
                            }
                            while (tabt.count < list.count) {
                                print(Date(),"DEBUG","wait",tabt.count,list.count)
                                usleep(550000)
                            }
                            lock.withLock {
                                tabp = tabt
                            }
                        }
                    }
                    burl!.stopAccessingSecurityScopedResource()
                }
            }
            if (slee == 0) { slee = 1 }
            if ((outp == "") && (slee != 0)) { sleep(5) }
        }
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

    func meta(path:String?, pobj:mdat?) {
        let objc = view!
        let hold = \ContentView.hold
        if (path != nil) {
            let purl = URL(fileURLWithPath:path!)
            let aset = AVURLAsset(url:purl)
            Task {
                let maps = [[0, "©nam"], [1, "©ART"], [2, "©alb"], [3, "©gen"]]
                var info = [["", mkda()], ["", mkda()], ["", mkda()], ["", mkda()]]
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
                let modd = mods(path:path!, back:"---")
                let temp = make(path:path!, song:minf[0][0] as! String, name:minf[1][0] as! String, albm:minf[2][0] as! String, genr:minf[3][0] as! String, tstr:tsec, date:modd, null:"*", time:csec)
                lock.withLock {
                    tabt.append(temp)
                }
            }
        } else {
            objc[keyPath:hold] = pobj!
        }
    }
}

func noco() -> Color {
    return Color.init(red:0.0, green:0.0, blue:0.0, opacity:0.0)
}

func butn(kind:String, size:CGFloat, extr:[CGFloat], colr:Color, actn:@escaping () -> Void) -> some View {
    let objc = Button(action:actn) {
        Image(systemName:kind).resizable().scaledToFit().frame(width:size, height:size).foregroundColor(colr)
    }.buttonStyle(.borderless)
    return Rectangle()
        .fill(noco()).frame(width:size+extr[0], height:size+extr[1]).overlay(objc)
}

func txts(strs:String, size:CGFloat, colr:Color, kind:Int, bold:Int) -> some View {
    var ssiz = size
    let name = ["Menlo", "Courier New"]
    if (kind == 0) {
        /* no-op */
    } else if (kind == 1) {
        ssiz = (ssiz + 2.0)
    }
    return Text(strs).font(Font.custom(name[kind], size:ssiz).weight((bold != 1) ? .regular : .bold)).foregroundColor(colr)
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

    @State var vers = "1.0.1"
    @State var mode = "play.circle"
    @State var mcol = "b"
    @State var prog = 0.00
    @State var sldr = true
    @State var edit = false
    @State var time = ["00:00", "00:00"]
    @State var srch = ""
    @State var last = 0
    @State var stat = "0"
    @State var xfer: UUID?
    @State var hold: mdat?
    @State var tabl = [] as [mdat]
    @State var baup = [] as [mdat]
    @State var sels = Set<mdat.ID>()
    @State var srts = [] as [KeyPathComparator<mdat>]
    @State var nobj = note()

    var body: some View {
        let _ = main()
        let epad = 8.0
        let ssiz = 600.0

        VStack {
            HStack {
                HStack {
                    HStack {
                        HStack {
                            butn(kind:"arrow.left.circle", size:38.0, extr:[epad, 0.0], colr:colr(k:"b"), actn:prev)
                            butn(kind:mode, size:46.0, extr:[epad, 0.0], colr:colr(k:mcol), actn:bply)
                            butn(kind:"arrow.right.circle", size:38.0, extr:[epad, 0.0], colr:colr(k:"b"), actn:more)
                        }
                    }.frame(width:230.0).offset(x:-1.00, y:1.99)
                    HStack {
                        VStack {
                            butn(kind:"star.circle", size:28.0, extr:[0.0, epad*1.0], colr:colr(k:"b"), actn:star)
                            butn(kind:"viewfinder.circle", size:28.0, extr:[0.0, epad*1.0], colr:colr(k:"b"), actn:fndr)
                        }.offset(x:-9.99)
                        RoundedRectangle(cornerRadius:19.0).stroke(colr(k:"b"), lineWidth:3.0).fill(colr(k:"z")).frame(width:ssiz, height:88.0).overlay(
                        VStack {
                            txts(strs:gets(kind:0), size:17.0, colr:colr(k:"t"), kind:0, bold:0).offset(y:-5.09)
                            txts(strs:gets(kind:1), size:13.0, colr:colr(k:"t"), kind:0, bold:0).offset(y:1.99)
                            HStack {
                                txts(strs:time[0], size:11.0, colr:colr(k:"l"), kind:1, bold:1).padding(.trailing, 8.0).offset(y:-0.39)
                                slid(locks:$sldr, edits:$edit, value:$prog, colrs:colr(k:"b"), backg:colr(k:"t")).frame(width:ssiz*0.50, height:13.0).offset(y:-0.99)
                                txts(strs:time[1], size:11.0, colr:colr(k:"l"), kind:1, bold:1).padding(.leading, 8.0).offset(y:-0.39)
                            }.offset(y:5.09)
                        })
                    }.frame(maxWidth:.infinity).frame(height:16.0)
                    HStack {  }.padding(.leading, 24.0)
                    HStack {
                        TextField("Filter", text:$srch).frame(width:176.0).foregroundColor(colr(k:"t"))
                            .onChange(of:srch) { _, vals in
                                last = Int(Date().timeIntervalSince1970)
                                filt()
                            }
                            .disableAutocorrection(true)
                            .textFieldStyle(.plain)
                            .font(Font.custom("Menlo", size:13.0).weight(.bold))
                            .padding(EdgeInsets(top:1.5, leading:5.5, bottom:1.5, trailing:5.5))
                            .overlay(RoundedRectangle(cornerRadius:9.0).inset(by:-9.0).stroke(colr(k:"b"), lineWidth:3.0))
                        butn(kind:"plus.circle", size:30.0, extr:[0.0, 0.0], colr:colr(k:"b"), actn:nill).offset(x:12.0)
                    }.offset(y:-1.09)
                    HStack {  }.padding(.leading, 28.0)
                }.padding(EdgeInsets(top:12.0, leading:0.0, bottom:12.0, trailing:0.0))
            }.padding(.bottom, 20.0)
            HStack {
                HStack {
                    ScrollViewReader { proxy in
                        Table(tabl, selection:$sels, sortOrder:$srts, columnCustomization:$cols) {
                            TableColumn("*") { temp in
                                if (temp.null == "*") {
                                    txts(strs:temp.null, size:15.0, colr:colr(k:"l"), kind:1, bold:1)
                                } else {
                                    txts(strs:" ", size:15.0, colr:colr(k:"l"), kind:1, bold:1)
                                        .overlay(Image(systemName:"star.circle"))
                                }
                            }.customizationID("*").alignment(.center)
                            TableColumn("Track", value:\.song) { temp in
                                txts(strs:temp.song, size:13.0, colr:colr(k:"l"), kind:0, bold:0)
                            }.customizationID("Track")
                            TableColumn("Artist", value:\.name) { temp in
                                txts(strs:temp.name, size:13.0, colr:colr(k:"l"), kind:0, bold:0)
                            }.customizationID("Artist")
                            TableColumn("Album", value:\.albm) { temp in
                                txts(strs:temp.albm, size:13.0, colr:colr(k:"l"), kind:0, bold:0)
                            }.customizationID("Album")
                            TableColumn("Genre", value:\.genr) { temp in
                                txts(strs:temp.genr, size:13.0, colr:colr(k:"l"), kind:0, bold:0)
                            }.customizationID("Genre")
                            TableColumn("Time", value:\.tstr) { temp in
                                txts(strs:temp.tstr, size:11.0, colr:colr(k:"l"), kind:1, bold:1)
                            }.customizationID("Time").alignment(.center)
                            TableColumn("Date", value:\.date) { temp in
                                txts(strs:temp.date, size:11.0, colr:colr(k:"l"), kind:1, bold:1)
                            }.customizationID("Date")
                        }.onChange(of:srts) { _, vals in
                            nobj.glob().withLock {
                                srts = [vals[0]]
                                baup.sort(using:srts)
                                if (srch == "") { tabl = baup }
                                nobj.sync(inpt:baup)
                                srtz = "\(vals[0].keyPath):\(vals[0].order)"
                            }
                        }.onChange(of:sels) { _, vals in
                            if (xfer != nil) {
                                nobj.glob().withLock {
                                    withAnimation {
                                        proxy.scrollTo(xfer!)
                                    }
                                    sels.removeAll()
                                    sels.insert(xfer!)
                                    xfer = nil
                                }
                            }
                        }.opacity(0.99)
                        .alternatingRowBackgrounds(.disabled)
                        .scrollContentBackground(.hidden)
                        .background(colr(k:"w"))
                        .contextMenu(forSelectionType:mdat.ID.self) { item in
                            /* no-op */
                        } primaryAction: { item in
                            for trak in tabl {
                                if (item.contains(trak.id)) {
                                    nobj.halt()
                                    let _ = play(objc:trak, over:1)
                                }
                            }
                        }
                    }
                }.padding(EdgeInsets(top:0.0, leading:11.0, bottom:11.0, trailing:11.0))
            }.frame(maxWidth:.infinity, maxHeight:.infinity)
            HStack {
                HStack {
                    let stts = stat.replacingOccurrences(of:",", with:",")
                    txts(strs:String(format:"%@ tracks", stts).lpadr(toLength:19, withPad:" ", padSide:0), size:13.0, colr:colr(k:"t"), kind:1, bold:1).offset(x:0.00, y:-0.19)
                }
                HStack {
                    Rectangle().frame(width:1.0, height:1.0).foregroundColor(noco())
                        .overlay(RoundedRectangle(cornerRadius:1.0).frame(width:1.9, height:19.0).foregroundColor(colr(k:"t")).offset(x:0.00, y:-1.19))
                }.padding(EdgeInsets(top:0.0, leading:11.0, bottom:0.0, trailing:11.0))
                HStack {
                    txts(strs:String(format:"version %@", vers).lpadr(toLength:19, withPad:" ", padSide:1), size:13.0, colr:colr(k:"t"), kind:1, bold:1).offset(x:0.00, y:-0.19)
                }
            }.padding(.bottom, 5.0).offset(x:-5.99, y:-5.99)
        }
    }

    func colr(k:String) -> Color {
        let bcol = Color.init(red:0.13, green:0.55, blue:0.87, opacity:0.95)
        let tcol = Color.init(red:0.91, green:0.87, blue:0.71, opacity:0.95)
        let wcol = Color.init(red:0.13, green:0.13, blue:0.13, opacity:0.53)
        let lcol = tcol.opacity(0.79)
        let zcol = tcol.opacity(0.09)
        if (k == "b") { return bcol }
        if (k == "t") { return tcol }
        if (k == "l") { return lcol }
        if (k == "z") { return zcol }
        if (k == "w") { return wcol }
        return noco()
    }

    func main() {
        nobj.main(objc:self)
    }

    func form(inpt:Int64) -> String {
        let mins = (inpt / 60)
        let secs = (inpt % 60)
        return String(format:"%02d:%02d", mins, secs)
    }

    func gets(kind:Int) -> String {
        if (hold != nil) {
            if (kind == 0) { return String(format:"%@", hold!.song) }
            if (kind == 1) { return String(format:"%@ [%@]", hold!.name, hold!.genr) }
        } else {
            if (tabl.count < 1) {
                if (kind == 0) { return "Loading Tracks" }
                if (kind == 1) { return "..." }
            } else {
                if (kind == 0) { return "Tracks Loaded" }
                if (kind == 1) { return tabl.count.formatted() }
            }
        }
        return " "
    }

    func symb(r:Int) {
        if (r != 1) {
            mode = "play.circle"
            mcol = "b"
        } else {
            mode = "pause.circle"
            mcol = "t"
        }
    }

    func play(objc:mdat, over:Int) -> Int {
        let chks = nobj.gets()
        var r = 0
        if ((chks != 1) || (over == 1)) {
            if (nobj.pobj == nil) {
                r = nobj.play(mobj:objc)
                print(Date(),"DEBUG","play",objc,over,r)
            } else {
                r = nobj.play(mobj:nil)
                print(Date(),"DEBUG","resu",objc,over,r)
            }
        } else {
            nobj.stop()
            r = 0
            print(Date(),"DEBUG","paus",objc,over,r)
        }
        print(Date(),"DEBUG","symb",objc,over,r)
        symb(r:r)
        return 0
   }

    func more() {
        let r = nobj.next(iidx:1, over:0)
        symb(r:r)
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
    }

    private func bply() {
        if (tabl.count > 0) {
            if (hold == nil) { hold = tabl[0] }
            if (nobj.indx > -1) { hold = tabl[nobj.indx] }
            let _ = play(objc:hold!, over:0)
        }
    }

    private func star() {
        if (hold != nil) {
            nobj.glob().withLock {
                xfer = hold!.id
                sels.insert(UUID())
            }
        }
    }

    private func fndr() {
        if (!sels.isEmpty) {
            for item in tabl {
                if (sels.contains(item.id)) {
                    let urlp = URL(fileURLWithPath:item.path)
                    NSWorkspace.shared.activateFileViewerSelecting([urlp])
                }
            }
        }
    }

    private func filt() {
        let nows = Int(Date().timeIntervalSince1970)
        if ((nows - last) <= 1) {
            DispatchQueue.main.asyncAfter(deadline:.now() + 0.50) { filt() }
        } else {
            if (srch != "") {
                do {
                    let regx = try Regex("^.*"+srch+".*$")
                    var temp = [] as [mdat]
                    for item in baup {
                        if let _ = item.hash.wholeMatch(of:regx) {
                            temp.append(item)
                        }
                    }
                    nobj.glob().withLock {
                        tabl = temp
                        stat = tabl.count.formatted()
                    }
                } catch {
                    /* no-op */
                }
            } else {
                nobj.glob().withLock {
                        tabl = baup
                        stat = tabl.count.formatted()
                    }
            }
        }
    }

    private func nill() {
        /* no-op */
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
