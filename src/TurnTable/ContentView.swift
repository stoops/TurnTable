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
    func version() -> String { return "1.1.530" }
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
    let covr: String
    let null: String
    let hash: String
    let dobj: Date
    let time: Int64
}

struct tabs: View {

    @Binding var objc: bind
    @Binding var sees: UUID?
    @Binding var sels: UUID?
    @Binding var scro: UUID?
    @Binding var srts: String
    @Binding var refr: UUID

    @State var sync = CGFloat.zero

    @State var flag = 0
    @State var srtw = 11.0
    @State var aftr = 11.0
    @State var radr = 9.0
    @State var rowp = 9.0
    @State var offz = 5.0
    @State var sepp = 10.0
    @State var sizh = 25.0
    @State var minw = 55.0
    @State var sizr = 0.79
    @State var rowr = 0.91
    @State var opac = 0.87
    @State var insl = EdgeInsets(top:3.09, leading:3.09, bottom:3.09, trailing:3.09)
    @State var refi = UUID()

    struct bind {
        struct mcol {
            var cols = [] as [String]
            var keys = [] as [String]
            var ordr = [] as [Int]
            var sizs = [] as [CGFloat]
            var hist = [] as [[CGFloat]]
        }

        struct mclr {
            var body_bord = Color.white
            var body_radi = 9.99
            var body_wide = 3.99
            var head_back = Color.black.opacity(0.35)
            var head_text = Color.white
            var head_line_colr = Color.white
            var head_line_wide = 1.09
            var head_divr_colr = Color.white
            var head_divr_wide = 3.09
            var head_high_text = Color.black
            var head_high_back = Color.white
            var head_high_indx = -1
            var data_back = Color.black.opacity(0.35)
            var data_text = Color.white
            var data_high = Color.white.opacity(0.15)
            var data_line_colr = Color.white
            var data_line_wide = 0.39
            var data_rows_type = "rows"
        }

        var lock = NSLock()

        var last = 1970.secs()
        var iscr = 0
        var seei = -1
        var srti = -1
        var rows = [] as [[String]]
        var sell = [nil, nil] as [UUID?]

        var cols = mcol()
        var clrs = mclr()

        var cola = { (c:Int, r:Int, v:String, k:String, w:CGFloat, z:Color, s:UUID?, e:CGFloat) in
            if ((c > 0) || (r > 0)) { return AnyView(Text(v).foregroundColor(z).frame(width:w, alignment:.leading)) }
            else { return AnyView(Text(" ").foregroundColor(z)) }
        }
        var pact = {
            /* no-op */
        }

        func proc<Data>(_ data:Data, colz:KeyValuePairs<String,KeyPath<Data.Element, String>>) -> [[String]] where Data : RandomAccessCollection {
            var colt = ["*"] as [String]
            var coli = ["*"] as [String]
            for (keyn, keyp) in colz {
                let keyl = keyp.debugDescription.components(separatedBy:".")
                colt.append(keyn)
                coli.append((keyl.count > 1) ? keyl.last! : "")
            }
            return [colt, coli]
        }

        func main<Data>(_ data:Data, colz:KeyValuePairs<String,KeyPath<Data.Element, String>>, ordr:[Int], sizs:[CGFloat], hist:[[CGFloat]]) -> bind where Data : RandomAccessCollection {
            var outp = tabs.bind()
            let colt = outp.proc(data, colz:colz)
            outp.clrs = tabs.bind.mclr()
            outp.cols = tabs.bind.mcol(cols:colt[0], keys:colt[1], ordr:ordr, sizs:sizs, hist:hist)
            return outp
        }
    }

    struct okey: PreferenceKey {
        typealias Value = CGFloat
        static var defaultValue = CGFloat.zero
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value += nextValue()
        }
    }

    struct ddel: DropDelegate {
        @Binding var objc: bind
        let indx: Int
        let dest: String
        func dropEntered(info:DropInfo) {
            objc.clrs.head_high_indx = indx
        }
        func dropExited(info:DropInfo) {
            objc.clrs.head_high_indx = -1
        }
        func performDrop(info:DropInfo) -> Bool {
            if (indx > 0) {
                getDrop(info:info, meth:1)
                return true
            }
            return false
        }
        func dropUpdated(info:DropInfo) -> DropProposal? {
            return DropProposal(operation: .move)
        }
        func setDrop(from:String) {
            if (indx > 0) {
                var idxs = [0, -1, -1, 0, -1, -1]
                for item in objc.cols.cols {
                    if (item == from) { idxs[1] = idxs[0] }
                    if (item == dest) { idxs[2] = idxs[0] }
                    idxs[0] += 1
                }
                if ((idxs[1] > 0) && (idxs[2] > 0)) {
                    for item in objc.cols.ordr {
                        if (item == idxs[1]) { idxs[4] = idxs[3] }
                        if (item == idxs[2]) { idxs[5] = idxs[3] }
                        idxs[3] += 1
                    }
                    if ((idxs[4] != -1) && (idxs[5] != -1)) {
                        var otmp = objc.cols.ordr
                        let valu = idxs[1]
                        if (idxs[4] > idxs[5]) {
                            otmp.remove(at:idxs[4])
                            otmp.insert(valu, at:idxs[5])
                        } else if (idxs[4] < idxs[5]) {
                            otmp.insert(valu, at:idxs[5]+1)
                            otmp.remove(at:idxs[4])
                        }
                        objc.cols.ordr = otmp
                    }
                }
            }
        }
        func getDrop(info:DropInfo, meth:Int) {
            if let item = info.itemProviders(for:["public.text"]).first {
                item.loadItem(forTypeIdentifier:"public.text", options:nil) { (data, err) in
                    if let text = data as? Data {
                        let strs = String(decoding:text, as:UTF8.self)
                        if (meth == 1) { setDrop(from:strs) }
                    }
                }
            }
        }
    }

    var body: some View {
        ZStack {
            ZStack {
                VStack(spacing:0) {
                    GeometryReader { geome in
                        ScrollViewReader { proxy in
                            VStack(spacing:0) {
                                ScrollView([.horizontal], showsIndicators:false) {
                                    VStack(spacing:0) {
                                        Spacer()
                                        HStack {
                                            sepr(i:-1, h:sizh*sizr, e:true, w:geome.size.width, c:Color.clear).offset(y:-1*(offz/2.75))
                                            ForEach(0..<objc.cols.cols.count, id:\.self) { i in
                                                cold(i:i+1, j:-1, w:geome.size.width, c:Color.clear).offset(y:-0.99)
                                                sepr(i:i+1, h:sizh*sizr, e:true, w:geome.size.width, c:objc.clrs.body_bord).offset(y:-1*(offz/2.75))
                                            }
                                            Color.clear.frame(width:aftr, height:1.0).contentShape(Rectangle())
                                            Spacer()
                                        }.frame(minWidth:geome.size.width).offset(y:-0.99)
                                            .offset(x:-sync)
                                        line(i:1, j:-1, k:1, s:objc.clrs.head_line_wide, c:Color.clear, q:-1).offset(y:-1*(offz/2.75))
                                        Spacer()
                                    }
                                }.foregroundColor(Color.clear).background(Color.clear)
                                Spacer()
                            }.frame(height:sizh+offz).padding(.top, offz)
                            VStack(spacing:0) {
                                ScrollView([.horizontal, .vertical], showsIndicators:(objc.rows.count < 1) ? false : true) {
                                    VStack(spacing:0) {
                                        LazyVStack(spacing:0) {
                                            if (objc.rows.count < 1) {
                                                HStack {
                                                    Color.clear.frame(minWidth:geome.size.width).contentShape(Rectangle())
                                                    Spacer()
                                                }
                                            }
                                            ForEach(0..<objc.rows.count, id:\.self) { j in
                                                let u = UUID(uuidString:objc.rows[j][0])
                                                HStack {
                                                    sepr(i:-1, h:sizh*sizr, e:false, w:geome.size.width, c:Color.clear)
                                                    ForEach(0..<objc.rows[j].count, id:\.self) { i in
                                                        rowd(i:i+1, j:j+1, w:geome.size.width, c:Color.clear)
                                                        sepr(i:i+1, h:sizh*sizr, e:false, w:geome.size.width, c:Color.clear)
                                                    }
                                                    Color.clear.frame(width:aftr, height:1.0).contentShape(Rectangle())
                                                    Spacer()
                                                }.id((u != nil) ? u! : UUID(uuidString:"0"))
                                                    .frame(minWidth:geome.size.width)
                                                    .frame(height:(sizh+offz)*rowr)
                                                    .contentShape(Rectangle())
                                                    .background() { back(u:u, s:sels, r:j) }
                                                    .onTapGesture {
                                                        let secs = 1970.secs()
                                                        if (u != nil) {
                                                            objc.lock.withLock {
                                                                sels = u!
                                                                objc.sell.append(sels!)
                                                                while (objc.sell.count > 2) { objc.sell.removeFirst() }
                                                                if ((objc.sell[0] != nil) && (objc.sell[1] != nil)) {
                                                                    if ((objc.sell[0]! == objc.sell[1]!) && ((secs - objc.last) <= 0.50)) {
                                                                        objc.pact()
                                                                    }
                                                                }
                                                                objc.last = secs
                                                            }
                                                        }
                                                    }
                                                line(i:-1, j:j, k:1, s:objc.clrs.data_line_wide, c:Color.clear, q:1)
                                            }
                                        }
                                        .background(GeometryReader { tempg in
                                            Color.clear.preference(key:okey.self, value:-tempg.frame(in:.named("scro")).origin.x)
                                        }).onPreferenceChange(okey.self) { value in
                                            sync = value
                                        }
                                        Spacer()
                                    }.frame(minHeight:geome.size.height).padding(.top, offz/1.9)
                                }.coordinateSpace(name:"scro")
                            }.padding(.top, -1 * (offz*1.55))
                            VStack(spacing:0) {  }
                            .onChange(of:objc.iscr) {
                                seek()
                                if (scro != nil) {
                                    withAnimation {
                                        proxy.scrollTo(scro!, anchor:.leading)
                                    }
                                }
                            }.onChange(of:refr) {
                                seek()
                            }
                        }.foregroundColor(Color.clear).background(Color.clear)
                    }
                }
            }.padding(EdgeInsets(top:objc.clrs.body_wide, leading:objc.clrs.body_wide, bottom:objc.clrs.body_wide, trailing:objc.clrs.body_wide))
            .background() { ZStack {
                let magp = 0.99
                let magb = 1.99
                let radi = objc.clrs.body_radi
                let bord = objc.clrs.body_wide
                let offy = objc.clrs.head_line_wide
                VStack(spacing:0) {
                    RoundedRectangle(cornerRadius:radi-magb).frame(maxHeight:.infinity).foregroundColor(objc.clrs.data_back.opacity(opac)).padding(EdgeInsets(top:bord-magp, leading:bord-magp, bottom:bord-magp, trailing:bord-magp))
                }
                VStack(spacing:0) {
                    RoundedRectangle(cornerRadius:radi-magb).frame(height:sizh+offz+offy).foregroundColor(objc.clrs.head_back.opacity(opac)).padding(EdgeInsets(top:bord-magp, leading:bord-magp, bottom:bord-magp, trailing:bord-magp))
                    Spacer()
                }
                RoundedRectangle(cornerRadius:radi).inset(by:-1*0.09).stroke(objc.clrs.body_bord.opacity(opac), lineWidth:bord)
            } }
        }.padding(insl).onAppear {
            main(inpl:objc.cols.cols)
            refr = UUID()
        }
    }

    func main(inpl:[String]) {
        var i = 0
        for _ in inpl {
            if (!(objc.cols.ordr.contains(i))) {
                objc.cols.ordr.append(i)
            }
            if (i >= objc.cols.sizs.count) {
                objc.cols.sizs.append(0.0)
            }
            if (i >= objc.cols.hist.count) {
                objc.cols.hist.append([0.0, 0.0, 0.0, 0.0])
            }
            i = (i + 1)
        }
    }

    func seek() {
        var sidx = -1
        if (sels != nil) {
            var ridx = 0
            for item in objc.rows {
                let uidt = UUID(uuidString:item[0])
                if ((uidt != nil) && (sels! == uidt!)) {
                    sidx = ridx
                }
                ridx += 1
            }
        }
        var cidx = 0
        for item in objc.cols.keys {
            if (srts.lowercased().contains(item.lowercased())) {
                objc.srti = objc.cols.ordr[cidx]
            }
            cidx += 1
        }
        objc.seei = sidx
        refi = UUID()
    }

    func perc(s:CGFloat, w:CGFloat, i:Int, n:Int) -> CGFloat {
        var r = s
        if ((r < 1.0) && (i > 0) && (n > 1)) {
            r = (w / CGFloat(n - 1))
        }
        r = max(minw, r)
        r = CGFloat(Int(r))
        return r
    }

    func sepr(i:Int, h:CGFloat, e:Bool, w:CGFloat, c:Color) -> AnyView {
        if (objc.cols.hist.count < objc.cols.cols.count) {
            return AnyView(EmptyView())
        }
        return AnyView(HStack {
            let l = 1
            let v = (i <= 0) ? sepp / 2.1 : sepp
            let k = (i > l) ? objc.cols.ordr[i - 1] : 0
            let x = (i > l) ? (objc.cols.hist[k][1] - objc.cols.hist[k][3]) : 0.0
            let z = objc.clrs.head_divr_wide
            Color.clear.frame(width:v, height:h).offset(x:x).contentShape(Rectangle()).overlay(
                Color.clear.frame(width:v*1.99, height:h*1.99).contentShape(Rectangle()).overlay(
                    RoundedRectangle(cornerRadius:radr).foregroundColor(c.opacity(opac))
                        .padding([.top, .bottom], ((h*1.99)-h)/2.1).padding([.leading, .trailing], ((v*1.99)-z)/2.1)
                ).onContinuousHover { p in
                    if ((i > l) && (e == true)) {
                        if (flag == 0) {
                            switch p {
                            case .active:
                                NSCursor.columnResize.set()
                            case .ended:
                                NSCursor.arrow.set()
                            }
                        }
                    }
                }.gesture(
                    DragGesture(minimumDistance:0)
                    .onChanged { v in
                        if ((i > l) && (e == true)) {
                            flag = 1
                            NSCursor.columnResize.set()
                            let j = objc.cols.ordr[i - 1]
                            let s = perc(s:objc.cols.sizs[j], w:w, i:j, n:objc.cols.cols.count)
                            let m = (v.location.x - ((sepp * 1.99) / 2))
                            var f = 0
                            var z = objc.cols.hist[j]
                            if (abs(v.translation.width) == 0.0) {
                                z = [m, m, m, m] as [CGFloat]
                                f = 2
                            }
                            var a = z[0]
                            var b = z[3]
                            if (f == 0) {
                                a = (z[0] + v.translation.width)
                                b = 0.0
                                f = 1
                            }
                            let chks = (s + (a - z[0]) + z[2])
                            if (chks >= minw) {
                                objc.cols.sizs[j] = chks
                                if (f == 1) {
                                    objc.cols.hist[j][1] = a
                                    objc.cols.hist[j][3] = b
                                } else if (f == 2) {
                                    objc.cols.hist[j] = z
                                }
                            } else {
                                objc.cols.sizs[j] = s
                            }
                            seek()
                        }
                    }
                    .onEnded() { v in
                        if ((i > l) && (e == true)) {
                            let j = objc.cols.ordr[i - 1]
                            objc.cols.hist[j] = [0.0, 0.0, 0.0, 0.0]
                            NSCursor.arrow.set()
                            flag = 0
                        }
                    }
                )
            )
        })
    }

    func cold(i:Int, j:Int, w:CGFloat, c:Color) -> AnyView {
        if (objc.cols.sizs.count < objc.cols.cols.count) {
            return AnyView(EmptyView())
        }
        let iidx = objc.cols.ordr[i-1]
        let strs = objc.cols.cols[iidx]
        let sizt = objc.cols.sizs[iidx]
        let colr = (objc.clrs.head_high_indx != iidx) ? objc.clrs.head_text : objc.clrs.head_high_text
        let bgco = (objc.clrs.head_high_indx != iidx) ? Color.clear : objc.clrs.head_high_back
        let sizw = perc(s:(iidx > 0) ? sizt : 0.0, w:w, i:iidx, n:objc.cols.cols.count)
        let srte = (objc.srti == iidx) ? srtw : 0.0
        return AnyView(objc.cola(iidx, -1, objc.cols.cols[iidx], objc.cols.keys[iidx], sizw, colr, sees, srte)
            .contentShape(Rectangle())
            .background() {
                RoundedRectangle(cornerRadius:3.0).fill(bgco).padding([.top, .bottom], offz * 0.95).padding([.leading, .trailing], -1 * (offz * 1.75)).offset(y:-0.99)
            }.onTapGesture {
                if (iidx > 0) {
                    let defs = "forward"
                    let prop = objc.cols.keys[iidx]
                    var dirs = (!(srts.lowercased().contains(defs)) ? defs : "reverse")
                    if (!(srts.lowercased().contains(prop))) { dirs = defs }
                    srts = (prop + ":" + dirs)
                    objc.srti = iidx
                }
            }.onDrag {
                NSItemProvider(object:String((iidx > 0) ? strs : "---") as NSString)
            }.onDrop(of:["public.text"], delegate:ddel(objc:$objc, indx:iidx, dest:strs))
        )
    }

    func rowd(i:Int, j:Int, w:CGFloat, c:Color) -> AnyView {
        if (objc.cols.sizs.count < objc.cols.cols.count) {
            return AnyView(EmptyView())
        }
        let iidx = objc.cols.ordr[i-1]
        let sizt = objc.cols.sizs[iidx]
        let sizw = perc(s:(iidx > 0) ? sizt : 0.0, w:w, i:iidx, n:objc.cols.cols.count)
        let srte = (objc.srti == iidx) ? srtw : 0.0
        return AnyView(objc.cola(-1 * j, iidx, objc.rows[j-1][iidx], objc.cols.keys[iidx], sizw, objc.clrs.data_text, sees, srte))
    }

    func back(u:UUID?, s:UUID?, r:Int) -> some View {
        let maxp = max(rowp/3.99, rowp-5.99)
        var colr = Color.clear
        if (objc.clrs.data_rows_type == "rows") {
            if ((r % 2) == 1) {
                colr = objc.clrs.data_high.opacity(0.11)
            }
        }
        if ((u != nil) && (s != nil) && (u! == s!)) {
            colr = objc.clrs.data_high.opacity(opac/1.35)
        }
        return VStack(spacing:0) {
            RoundedRectangle(cornerRadius:radr/1.75).fill(colr).padding([.leading, .trailing], maxp).padding([.top, .bottom], -1 * (2 * objc.clrs.data_line_wide))
        }
    }

    func line(i:Int, j:Int, k:Int, s:CGFloat, c:Color, q:Double) -> some View {
        var z = c
        if (i > -1) {
            z = objc.clrs.head_line_colr
        }
        if (j > -1) {
            if (objc.clrs.data_rows_type == "line") {
                z = objc.clrs.body_bord
            }
            if (objc.seei > -1) {
                if ((j == (objc.seei - 1)) || (j == objc.seei)) {
                    z = Color.clear
                }
            }
        }
        return VStack(spacing:0) {
            let v = 1.00
            let h = max(v, s)
            Color.clear.frame(height:h).contentShape(Rectangle()).overlay(
                Color.clear.frame(height:h*1.99).contentShape(Rectangle()).overlay(
                    RoundedRectangle(cornerRadius:radr).stroke(z, lineWidth:s).foregroundColor(Color.clear).frame(height:v)
                        .padding([.top, .bottom], ((h*1.99)-h)/2.1).padding([.leading, .trailing], q * rowp)
                )
            )
        }
    }

    func cola(_ actn:@escaping (Int, Int, String, String, CGFloat, Color, UUID?, CGFloat) -> AnyView) -> Self {
        self.objc.cola = actn
        return self
    }

    func pact(_ actn:@escaping () -> Void) -> Self {
        self.objc.pact = actn
        return self
    }

    func load<Data>(_ data:Data, iden:KeyPath<Data.Element, UUID>, colz:KeyValuePairs<String,KeyPath<Data.Element, String>>) -> Self where Data : RandomAccessCollection {
        var colt = [] as [[String]]
        var rowt = [] as [[String]]
        colt = self.objc.proc(data, colz:colz)
        for item in data {
            let uids = item[keyPath:iden].description
            var rowz = [uids] as [String]
            for (_, keyp) in colz {
                rowz.append(item[keyPath:keyp])
            }
            rowt.append(rowz)
        }
        main(inpl:colt[0])
        self.objc.cols.cols = colt[0]
        self.objc.cols.keys = colt[1]
        self.objc.rows = rowt
        self.objc.iscr += 1
        refr = UUID()
        return self
    }

}

struct slid: View {
    @Binding var locks: Bool
    @Binding var edits: Bool
    @Binding var moved: Bool
    @Binding var value: CGFloat
    @Binding var colrg: Color
    @Binding var colrb: Color
    @Binding var highg: Color
    @Binding var highb: Color

    var fills: Bool

    @State var cobjg: Color?
    @State var cobjb: Color?
    @State var offxs: CGFloat = 0.0
    @State var coord: CGFloat = 0.0
    @State var brite: CGFloat = 0.19

    var body: some View {
        GeometryReader { gr in
            let radial = (round((gr.size.height * 0.87) * 1000) / 1000) as CGFloat
            let radius = (round((gr.size.height * 0.69) * 1000) / 1000) as CGFloat
            let minval = (round((gr.size.width * 0.005) * 1000) / 1000) as CGFloat
            let maxval = (round(((gr.size.width * 0.995) - radial) * 1000) / 1000) as CGFloat

            ZStack {
                RoundedRectangle(cornerRadius:radius)
                    .inset(by:-1.99)
                    .stroke((cobjg == nil) ? colrg : cobjg!, lineWidth:1.59)
                    .brightness((cobjg == nil) ? 0.00 : brite)
                    .overlay(ZStack {
                        RoundedRectangle(cornerRadius:radius).inset(by:-1.09).foregroundColor(Color.black.opacity(0.11))
                        if (fills) {
                            HStack {
                                Color.clear.frame(width:1.0, height:1.0).contentShape(Rectangle()).overlay(
                                    RoundedRectangle(cornerRadius:radius)
                                        .inset(by:-1.09)
                                        .foregroundColor((cobjb == nil) ? colrb : cobjb!).opacity(0.35)
                                        .frame(width:safes(valus:self.value, minms:minval, maxms:maxval, divrs:1.0)+(radial/1.1), height:radial)
                                        .offset(x:(safes(valus:self.value, minms:minval, maxms:maxval, divrs:1.0)/2.0)+(radial/2.1), y:0.0)
                                )
                                Spacer()
                            }
                        }
                    })
                HStack {
                    Color.clear.frame(width:radial, height:radial).contentShape(Rectangle()).overlay(
                        Color.clear.frame(width:radial*1.99, height:radial*1.99).contentShape(Rectangle()).overlay(
                            Circle()
                                .padding(radial/1.9)
                                .foregroundColor((cobjb == nil) ? colrb : cobjb!)
                                .brightness(0.19)
                                .brightness((cobjg == nil) ? 0.00 : brite)
                        ).offset(x:offxs, y:0.0)
                    )
                    Spacer()
                }
            }.onAppear {
                offxs = safes(valus:value, minms:minval, maxms:maxval, divrs:1.0)
            }.onChange(of:value) {
                offxs = safes(valus:value, minms:minval, maxms:maxval, divrs:1.0)
            }.gesture(
                DragGesture(minimumDistance:0)
                .onChanged { v in
                    if (!locks) {
                        self.edits = true
                        self.cobjg = self.highg
                        self.cobjb = self.highb
                        let temp = ((v.location.x - (radial / 2)) / maxval)
                        let valu = max(0.0, min(temp, 1.0))
                        self.value = valu
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

    func safes(valus:CGFloat, minms:CGFloat, maxms:CGFloat, divrs:CGFloat) -> CGFloat {
        if (locks) { return minms }
        let outp = (round(min(maxms, max(minms, valus * (maxms / divrs))) * 1000) / 1000)
        return outp
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

extension Int {
    func time() -> Int {
        return Int(Date().timeIntervalSince1970)
    }
    func secs() -> Double {
        return Date().timeIntervalSince1970
    }
    func date() -> Date {
        return Date(timeIntervalSince1970:0)
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
        return self.map { String(format:format, $0) }.joined()
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

class note: NotificationCenter, ObservableObject, @unchecked Sendable {
    @Published var view_sels: UUID?
    @Published var view_scro: UUID?
    @Published var view_sees: UUID?
    @Published var view_tabl = [] as [mdat]
    @Published var view_baup = [] as [mdat]
    @Published var view_coad = [] as [mdat]
    @Published var view_cobd = [] as [mdat]
    @Published var view_cocd = [] as [mdat]
    @Published var view_cobt = [] as [mdat]
    @Published var view_coct = [] as [mdat]
    @Published var view_shuf = [false, false] as [Bool]
    @Published var view_refl = 0
    @Published var view_opap = 0.00
    @Published var view_prog = 0.00 as CGFloat
    @Published var view_rotf = 0
    @Published var view_rota = 360.0
    @Published var view_srch = ""
    @Published var view_srtz = "band:forward"
    @Published var view_time = ["", ""]
    @Published var view_covr = ["", ""]
    @Published var view_slir = [true, false, false]
    @Published var view_srts = [] as [KeyPathComparator<mdat>]
    @Published var view_tabb = tabs.bind()

    @AppStorage("ClassBook")
    var book: Data?

    var lock = NSLock()
    var quel = NSLock()
    var ldat = 1970.date()
    var inil = [] as [String]
    var coaa = [] as [String]
    var coab = [] as [mdat]
    var coba = [] as [String]
    var cobb = [] as [mdat]
    var coca = [] as [String]
    var cocb = [] as [mdat]
    var taba = [] as [mdat]
    var tabp = [] as [mdat]
    var tabt = [] as [mdat]
    var imgs = [] as [String]
    var imgt = [] as [String]
    var pobj: AVPlayerItem?
    var plyr = AVPlayer()
    var save = [] as [mdat?]
    var stal = true
    var popu = true
    var outp = ""
    var flag = 0
    var stat = 0
    var load = 0
    var loas = 0
    var last = 0
    var plen = 0
    var indx = -1

    required override init() {
        print(Date(),"INFO","init")
    }

    func main() {
        let lets = "0123456789ACBDEF"
        let rnds = String((0..<8).map{ _ in lets.randomElement()! })
        if (inil.isEmpty) {
            inil.append(rnds)
            print(Date(),"INFO","rand",rnds)
            DispatchQueue.global(qos:.background).async { self.loop() }
        }
    }

    func glob() -> NSLock {
        return lock
    }

    func sync(inpt:[mdat]) {
        var news = -1
        if (indx > -1) {
            var iidx = 0
            for item in inpt {
                if (item.id == tabp[indx].id) {
                    news = iidx
                }
                iidx += 1
            }
        }
        tabp = inpt
        indx = news
    }

    func mkda() -> Data {
        return "".data(using:.utf8)!
    }

    func geth() -> mdat? {
        if (tabp.count > 0) {
            if ((-1 < indx) && (indx < tabp.count)) {
                return tabp[indx]
            }
        }
        indx = -1
        return nil
    }

    func getx() -> [mdat?] {
        var outp = [geth(), nil, nil]
        for item in tabp {
            if ((view_sels != nil) && (item.id == view_sels!)) {
                outp[1] = item
            }
            if ((view_scro != nil) && (item.id == view_scro!)) {
                outp[2] = item
            }
        }
        return outp
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

    func make(path:String, song:String, band:String, albm:String, genr:String, year:String, tstr:String, covr:String, null:String, dobj:Date, time:Int64) -> mdat {
        let form = DateFormatter()
        form.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let date = form.string(from:dobj)
        let hash = "song:\(song), band:\(band), albm:\(albm), genr:\(genr), year:\(year), time:\(tstr), date:\(date), path:\(path)"
        return mdat(path:path, song:song, band:band, albm:albm, genr:genr, year:year, tstr:tstr, date:date, covr:covr, null:null, hash:hash, dobj:dobj, time:time)
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
        let furl = FileManager.default.temporaryDirectory.appendingPathComponent("tt").appendingPathExtension("text")
        var csec = Int64(0)
        var cstr = form(inpt:csec)
        var tsec = Int64(0)
        var tstr = form(inpt:tsec)
        var psec = Double(0.0)
        var seek = 0
        var menl = 0
        while (0 == 0) {
            let secs = 1970.time()
            let exis = FileManager.default.fileExists(atPath:furl.path)
            if (exis) {
                print(Date(),"INFO","wait",furl.path)
                let _ = stop();
                sleep(5);
                continue;
            }
            if ((secs - load) >= (15 * 60)) {
                flag = 0
                loas = 1
                outp = ""
                save = getx()
                DispatchQueue.main.sync { self.view_opap = 0.99 }
                DispatchQueue.global(qos:.background).async { self.proc() }
                load = secs
            }
            let chks = gets()
            if (chks > 0) { DispatchQueue.main.sync { self.view_slir[0] = false } }
            else { DispatchQueue.main.sync { self.view_slir[0] = true } }
            if ((chks == 1) && (view_rotf != 1)) {
                DispatchQueue.main.sync {
                    self.view_rota = 0.0 ; self.view_rotf = 1
                }
            } else if ((chks != 1) && (view_rotf != 0)) {
                DispatchQueue.main.sync {
                    self.view_rota = 360.0 ; self.view_rotf = 0
                }
            }
            if ((stat == 1) && (chks < 0)) {
                let _ = next(iidx:1, over:1)
            }
            let hobj = geth()
            if ((indx > -1) && (hobj != nil)) {
                let cobj = plyr.currentTime()
                csec = divs(a:Int64(cobj.value), b:Int64(cobj.timescale))
                tsec = hobj!.time
                if (tsec < 1) { tsec = 1 }
            }
            if (tsec > 1) {
                if (pobj == nil) { csec = 0 }
                if (view_slir[2]) {
                    DispatchQueue.main.sync { self.view_slir[2] = false }
                    seek = 1
                }
                if (view_slir[1] || (seek != 0)) {
                    seek = 1
                    psec = (Double(view_prog) * Double(tsec))
                    csec = Int64(psec)
                    cstr = form(inpt:csec)
                    DispatchQueue.main.sync { self.view_time[0] = cstr }
                    if (!view_slir[1]) {
                        if (csec >= 0) {
                            plyr.seek(to:CMTime(seconds:Double(csec), preferredTimescale:CMTimeScale(1)))
                        }
                        seek = 0
                    }
                } else if (view_prog <= 1.0) {
                    cstr = form(inpt:csec)
                    tstr = form(inpt:tsec)
                    psec = (Double(csec) / Double(tsec))
                    if (cstr != view_time[0]) {
                        DispatchQueue.main.sync {
                            self.view_prog = psec
                            self.view_time[0] = cstr
                            self.view_time[1] = tstr
                        }
                    }
                }
            }
            let sobj = view_sees
            if (hobj == nil) {
                if (sobj != nil) {
                    DispatchQueue.main.sync { self.view_sees = nil }
                }
            } else {
                if ((sobj == nil) || (sobj! != hobj!.id)) {
                    DispatchQueue.main.sync { self.view_sees = hobj!.id }
                }
            }
            let numt = tabt.count
            let numb = tabp.count
            let nump = view_baup.count
            let numq = view_tabl.count
            if ((numt > 0) && (loas == 2)) {
                if ((secs - last) >= 3) {
                    let nils = "---"
                    let dumb = make(path:nils, song:nils, band:nils, albm:nils, genr:nils, year:nils, tstr:nils, covr:nils, null:nils, dobj:Date(), time:0)
                    let gsrt = gens(inpt:view_srtz)
                    if (flag == 1) {
                        lock.withLock {
                            print(Date(),"INFO","xfer",numt,numb,nump,numq,ldat)
                            tabp = tabt
                            tabp.sort(using:gsrt)
                            coaa = [nils] ; coab = [dumb]
                            coba = [nils] ; cobb = [dumb]
                            coca = [nils] ; cocb = [dumb]
                            var sels = [nil, nil, nil] as [UUID?]
                            var iidx = 0
                            for item in tabp {
                                if (save[0] != nil) {
                                    if (item.hash == save[0]!.hash) {
                                        indx = iidx ; sels[0] = item.id
                                    }
                                }
                                if (save[1] != nil) {
                                    if (item.hash == save[1]!.hash) {
                                        sels[1] = item.id
                                    }
                                }
                                if (save[2] != nil) {
                                    if (item.hash == save[2]!.hash) {
                                        sels[2] = item.id
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
                            imgs = imgt
                            DispatchQueue.main.async {
                                self.view_srts = gsrt
                                self.view_baup = self.tabp
                                if (self.view_srch == "") {
                                    self.view_tabl = self.view_baup
                                }
                                if (sels[0] != nil) {
                                    self.view_sees = sels[0]
                                }
                                if (sels[1] != nil) {
                                    self.view_sels = sels[1]
                                }
                                if (sels[2] != nil) {
                                    self.view_scro = sels[2]
                                    self.view_tabb.iscr += 1
                                }
                                self.view_coad = self.coab
                                self.view_cobd = self.cobb
                                self.view_cocd = self.cocb
                                self.view_cobt = self.cobb
                                self.view_coct = self.cocb
                                self.view_refl += 1
                            }
                        }
                    }
                    DispatchQueue.main.sync { self.view_opap = 0.00 }
                    quel.withLock {
                        imgt.removeAll()
                        tabt.removeAll()
                    }
                    loas = 3
                    last = secs
                }
            }
            if ((secs - menl) >= 3) {
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.0) {
                    if let wind = NSApp.windows.first {
                        wind.backgroundColor = NSColor(Color.clear)
                    }
                    let menu = NSApplication.shared.mainMenu
                    if (menu?.item(withTitle:"Data") == nil) {
                        let item: NSMenuItem? = menu?.item(withTitle:"Help")
                        if let item {
                            menu?.removeItem(item)
                        }
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
                        let mens = NSMenuItem(title:"Select", action:#selector(self.refs(_:)), keyEquivalent:"")
                        mens.isEnabled = true
                        mens.target = self
                        let menr = NSMenuItem(title:"Reload", action:#selector(self.refr(_:)), keyEquivalent:"")
                        menr.isEnabled = true
                        menr.target = self
                        let mend = NSMenuItem(title:"Data", action:nil, keyEquivalent:"")
                        mend.isEnabled = true
                        mend.target = self
                        mend.submenu = NSMenu(title:"Data")
                        mend.submenu?.autoenablesItems = true
                        mend.submenu?.addItem(mens)
                        mend.submenu?.addItem(menr)
                        menu?.addItem(mend)
                    }
                }
                menl = secs
            }
            print(Date(),"INFO","loop",inil,cstr,tstr,psec,stat,chks,indx,load,numt,numb,nump,numq)
            usleep(357000)
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
                iter += 1
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

    func stop() -> Int {
        if (gets() == 1) {
            plyr.pause()
            stat = 2
        }
        return 0
    }

    func halt() {
        let _ = stop()
        pobj = nil
        stat = 0
    }

    func next(iidx:Int, over:Int) -> Int {
        var jidx = 0
        var zidx = iidx
        var chks = gets()
        let pres = geth()
        let leng = view_tabl.count
        halt()
        if (tabp.count < 1) { return -1 }
        if (leng < 1) { return -2 }
        if (pres != nil) {
            var i = 0
            for item in view_tabl {
                if (item.hash == pres!.hash) { jidx = i }
                i = (i + 1)
            }
        }
        if (view_shuf[0] || view_shuf[1]) { zidx = Int.random(in:1..<leng) }
        jidx = (jidx + zidx)
        if (jidx < 0) { jidx = (leng - 1) }
        jidx = (jidx % leng)
        if (over == 1) { chks = over }
        let _ = play(mobj:view_tabl[jidx], over:chks)
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
                print(Date(),"INFO","book",temp,temp.relativePath,book!,stal)
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
                if (popu) {
                    popu = false
                    DispatchQueue.main.asyncAfter(deadline:.now() + 0.0) {
                        let opan = NSOpenPanel()
                        opan.allowsMultipleSelection = false
                        opan.canChooseDirectories = true
                        opan.canCreateDirectories = false
                        opan.canChooseFiles = false
                        let chek = opan.runModal()
                        if (chek == NSApplication.ModalResponse.OK) {
                            let curl = opan.url!
                            print(Date(),"INFO","open",curl)
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
            }
            burl = chkb()
            if (burl != nil) {
                if (burl!.startAccessingSecurityScopedResource()) {
                    let fold = burl!.relativePath //NSString(string:"~").expandingTildeInPath
                    let mune = FileManager.default.enumerator(atPath:fold) //let cmdl = String(format:"find '%@/' -type f 2>&1 | grep -Ei '(mp3|m4a)$'", fold)
                    print(Date(),"INFO","list",load,fold)
                    var temp = ""
                    while let elem = mune?.nextObject() as? String {
                        let fstr = elem.lowercased()
                        if (fstr.hasSuffix(".mp3") || fstr.hasSuffix(".m4a")) {
                            temp += (fold + "/" + elem + "\n")
                        }
                    }
                    if (temp != "") { //if let temp = try? exec(cmdl) {
                        var relo = 0
                        outp = temp.trimmingCharacters(in:.whitespaces)
                        if (outp != "") {
                            let mtmp = make(path:"", song:"", band:"", albm:"", genr:"", year:"", tstr:"", covr:"", null:"", dobj:Date(), time:0)
                            let list = outp.components(separatedBy:"\n").filter { !$0.isEmpty }
                            taba.removeAll()
                            imgt.removeAll()
                            for _ in list {
                                taba.append(mtmp)
                                imgt.append("")
                            }
                            var iidx = 0
                            for line in list {
                                meta(iidx:iidx, path:line)
                                iidx += 1
                            }
                            var lidx = 0
                            var lnum = 0
                            let mnum = 9
                            plen = 0
                            while ((plen < list.count) && (lnum < mnum)) {
                                usleep(753000)
                                quel.withLock {
                                    while ((plen < list.count) && (taba[plen].path != "")) {
                                        if (taba[plen].dobj > ldat) {
                                            ldat = taba[plen].dobj
                                            relo = 1
                                        }
                                        plen += 1
                                    }
                                }
                                if (plen == lidx) { lnum += 1 }
                                else { lnum = 0 }
                                lidx = plen
                                print(Date(),"INFO","wait",plen,lidx,list.count,lnum)
                            }
                            quel.withLock {
                                tabt.removeAll()
                                for item in taba {
                                    if (item.path != "") {
                                        tabt.append(item)
                                    }
                                }
                                if (tabt.count != tabp.count) {
                                    relo = 1
                                }
                                taba.removeAll()
                            }
                            if (relo == 1) { flag = 1 }
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
            if (i == 5) {
                let covr = (inpt[i][1] as? NSData) as Data? ?? mkda()
                if (covr.count > 0) {
                    info[i][0] = covr.base64EncodedString()
                }
            }
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
        let nils = "---"
        let purl = URL(fileURLWithPath:path)
        let aset = AVURLAsset(url:purl)
        Task {
            let maps = [["title", "©nam"], ["artist", "TPE2", "©ART"], ["albumName", "©alb"], ["type", "©gen"], ["TYE", "TYER", "TDRC", "©day"], ["PIC", "covr"]]
            var info = [[nils, mkda()], [nils, mkda()], [nils, mkda()], [nils, mkda()], [nils, mkda()], [nils, mkda()]]
            let dobj = try await aset.load(.duration)
            let data = try await aset.load(.metadata)
            let itun = try await aset.loadMetadata(for:AVMetadataFormat.iTunesMetadata)
            for item in data {
                if let name = item.commonKey?.rawValue, let vals = try await item.load(.value) {
                    var i = 0
                    for _ in maps {
                        let z = info[i][0] as? String ?? nils
                        if ((z == nils) && (maps[i].contains(name))) {
                            info[i][0] = vals
                            info[i][1] = vals
                        }
                        i += 1
                    }
                } else if let name = item.key?.description, let vals = try await item.load(.value) {
                    var i = 0
                    for _ in maps {
                        let z = info[i][0] as? String ?? nils
                        if ((z == nils) && (maps[i].contains(name))) {
                            info[i][0] = vals
                            info[i][1] = vals
                        }
                        i += 1
                    }
                }
            }
            var minf = dats(inpt:info)
            var i = 0
            for imap in maps {
                var z = minf[i][0] as? String ?? nils
                var j = 0
                while ((z == nils) && (j < imap.count)) {
                    let item = AVMetadataItem.metadataItems(from:itun, withKey:imap[j], keySpace:AVMetadataKeySpace.iTunes)
                    if let name = item.first, let vals = try await name.load(.value) {
                        info[i][0] = vals
                        info[i][1] = vals
                    }
                    let temp = dats(inpt:info)
                    minf[i][0] = temp[i][0]
                    minf[i][1] = temp[i][1]
                    z = minf[i][0] as? String ?? nils
                    j += 1
                }
                i += 1
            }
            var dmod = Date()
            let cidx = String(iidx)
            let covr = (minf[5][0] as! String)
            let csec = divs(a:Int64(dobj.value), b:Int64(dobj.timescale))
            let tsec = form(inpt:csec)
            let modd = mods(path:path, back:nils)
            if (modd != nil) { dmod = modd! }
            let temp = make(path:path, song:(minf[0][0] as! String), band:(minf[1][0] as! String), albm:(minf[2][0] as! String), genr:(minf[3][0] as! String), year:(minf[4][0] as! String), tstr:tsec, covr:cidx, null:"*", dobj:dmod, time:csec)
            if (iidx > -1) {
                quel.withLock {
                    if (iidx < self.taba.count) {
                        self.taba[iidx] = temp
                        self.imgt[iidx] = nils //covr
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.view_covr[0] = path
                    self.view_covr[1] = covr
                }
            }
        }
    }

    @MainActor func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }

    @objc func refs(_ sender: Any) {
        view_tabl.removeAll()
        view_baup.removeAll()
        view_refl += 1
        tabp.removeAll()
        tabt.removeAll()
        book = nil
        popu = true
        self.halt()
        self.refr(sender)
    }

    @objc func refr(_ sender: Any) {
        if ((loas == 0) || (loas == 3)) {
            ldat = 1970.date()
            load = 0
        }
    }

    @objc func wdow(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline:.now() + 0.0) {
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

    @AppStorage("TableSort")
    var srtz: String = "band:forward"

    @AppStorage("TablePlaylist")
    var plst: [[String]] = []

    @AppStorage("ShowPans")
    var shwp = false

    @AppStorage("ShowArtw")
    var shwa = false

    @AppStorage("ShowBtns")
    var shwb = false

    @AppStorage("ShowCols")
    var shwc = false

    @AppStorage("ShowMini")
    var shwm = false

    @AppStorage("TableShof")
    var shuf = [false, false]

    @AppStorage("ColorList")
    var clno = [[0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0]]

    @AppStorage("ColorMode")
    var mods = 0

    @AppStorage("WindowPref")
    var wina = [0.0, 0.0, 0.19, 0.0]

    @AppStorage("WindowSize")
    var winz = [0, 0, 0, 0]

    @AppStorage("WindowMini")
    var wini = [0, 0, 0, 0]

    @AppStorage("PlayerVolume")
    var volu = [1.00, 1.00, 1.00] as [CGFloat]

    @AppStorage("ColumnOrder")
    var cord = tabs.bind.mcol().ordr

    @AppStorage("ColumnSize")
    var csiz = tabs.bind.mcol().sizs

    @AppStorage("ColumnHist")
    var chis = tabs.bind.mcol().hist

    @AppStorage("RowStyle")
    var rows = 0

    @FocusState var isfo: Bool
    @FocusState var fobo: Bool
    @FocusState var pobo: Bool

    @State var clrs = [""].genr(inpt:["b", "g", "b", "!", "", ""], size:1000)
    @State var idxs = [99 /*icon*/, 97 /*stat*/, 95 /*filt*/, 93 /*list*/, 4 /*plst*/, 1 /*play*/]
    @State var idxf = [] as [[Any]]

    @State var imgl = 0
    @State var wins = 0
    @State var winc = Color.clear
    @State var winl = [Color.clear, Material.ultraThin, Material.thin, Material.regular, Material.thick, Material.ultraThick]
    @State var sldr = [Color.clear, Color.clear, Color.clear, Color.clear]
    @State var sldv = [Color.clear, Color.clear, Color.clear, Color.clear]
    @State var clco = [Color.clear, Color.clear, Color.clear, Color.clear, Color.clear, Color.clear, Color.clear, Color.clear]
    @State var bldr = [["band"], ["albm"], ["genr"], ["year"]]
    @State var mode = "play.circle"
    @State var keyz = 0
    @State var shws = false
    @State var fals = true
    @State var mute = false
    @State var sliv = [false, false, false]
    @State var name = ""
    @State var last = 0
    @State var pidx = -1
    @State var coas = Set<mdat.ID>()
    @State var cobs = Set<mdat.ID>()
    @State var cocs = Set<mdat.ID>()
    @State var styl = ["Light", "Dark"]
    @State var rowl = ["rows", "line"]
    @State var colu: KeyValuePairs = ["Track":\mdat.song, "Artist":\mdat.band, "Album":\mdat.albm, "Genre":\mdat.genr, "Year":\mdat.year, "Time":\mdat.tstr, "Date":\mdat.date]
    @State var tabz: tabs?
    @State var imgd: Image?
    @State var aart: Image?
    @State var refr = UUID()

    @StateObject var nobj = note()

    var body: some View {
        let epad = 8.0
        let ssiz = [600.0, 92.0]

        ZStack {
            VStack {
                HStack {
                    HStack {  }.padding(.leading, 4.0)
                    VStack {
                        let spcr = 1.15
                        let spcs = 0.75
                        let spcv = 1.75
                        HStack {
                            butv(kind:"backward.circle", size:27.0, extr:[epad*spcs, 0.0], iidx:21, clst:["b", "g", "b", "!"], pram:-1, actn:frev, actc:niln).offset(y:0.99)
                            butv(kind:"backward.end.circle", size:37.0, extr:[epad*spcr, 0.0], iidx:0, clst:["b", "g", "b", "!"], pram:-1, actn:prev, actc:niln)
                            butv(kind:plyi(), size:45.0, extr:[epad*spcr, 0.0], iidx:idxs[5], clst:["b", "g", "b", "~"], pram:-1, actn:bply, actc:plyz)
                            butv(kind:"forward.end.circle", size:37.0, extr:[epad*spcr, 0.0], iidx:2, clst:["b", "g", "b", "!"], pram:-1, actn:more, actc:niln)
                            butv(kind:"forward.circle", size:27.0, extr:[epad*spcs, 0.0], iidx:23, clst:["b", "g", "b", "!"], pram:-1, actn:ffwd, actc:niln).offset(y:0.99)
                        }.offset(y:0.99)
                        HStack {  }.overlay(
                            HStack {
                                butv(kind:muti(), size:24.0, extr:[epad*spcv, 0.0], iidx:75, clst:["b", "g", "b", "~"], pram:-1, actn:minv, actc:mutz)
                                slid(locks:$sliv[0], edits:$sliv[1], moved:$sliv[2], value:$volu[0], colrg:$sldv[0], colrb:$sldv[1], highg:$sldv[2], highb:$sldv[3], fills:true).frame(width:160.0, height:11.0)
                                    .offset(y:-0.09).onAppear {
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
                                butv(kind:"speaker.wave.2.circle", size:24.0, extr:[epad*spcv, 0.0], iidx:77, clst:["b", "g", "b", "!"], pram:-1, actn:maxv, actc:niln)
                            }.frame(width:1.0, height:1.0).padding(.top, 1.0).offset(x:0.00, y:19.69)
                        )
                    }.frame(width:250.0).padding(.top, 0.99).offset(x:15.99, y:-15.99)
                    HStack {  }.padding(.leading, 32.0)
                    HStack {
                        if (shwm == false) { Spacer(minLength:0.0) }
                        ZStack {
                            VStack {
                                VStack {
                                    txtv(strs:gets(kind:0), size:17.0, colr:colr(k:"t"), kind:0, bold:0).offset(y:-5.99).frame(width:ssiz[0]*0.89).offset(y:0.03)
                                    txtv(strs:gets(kind:1), size:15.0, colr:colr(k:"t"), kind:0, bold:0).offset(y:-0.99).frame(width:ssiz[0]*0.75).offset(y:0.69)
                                }.offset(y:0.99)
                                HStack {
                                    Color.clear.frame(width:1.0, height:1.0).contentShape(Rectangle()).overlay(ZStack {
                                        Circle().inset(by:-1.09).fill(colr(k:"z").opacity(0.93)).brightness(-0.39*1.09)
                                        butv(kind:"shuffle.circle", size:25.0, extr:[0.0, 0.0], iidx:3, clst:["b", "g", "b", "~"], pram:-1, actn:shfs, actc:shfz)
                                            .brightness(0.09*1.39)
                                            .onChange(of:nobj.view_shuf) {
                                                shuf = nobj.view_shuf
                                            }
                                    }.offset(x:19.99, y:-0.99))
                                    Spacer()
                                    txtv(strs:nobj.view_time[0], size:13.0, colr:colr(k:"t"), kind:1, bold:1).padding(.trailing, 8.0).offset(y:0.09)
                                    slid(locks:$nobj.view_slir[0], edits:$nobj.view_slir[1], moved:$nobj.view_slir[2], value:$nobj.view_prog, colrg:$sldr[0], colrb:$sldr[1], highg:$sldr[2], highb:$sldr[3], fills:false).frame(width:ssiz[0]*0.50, height:13.0).offset(y:-0.99).onAppear {
                                        sldr = [colr(k:"t"), colr(k:"b"), colr(k:"th"), colr(k:"bh")]
                                    }
                                    txtv(strs:nobj.view_time[1], size:13.0, colr:colr(k:"t"), kind:1, bold:1).padding(.leading, 8.0).offset(y:0.09)
                                    Spacer()
                                    Color.clear.frame(width:1.0, height:1.0).contentShape(Rectangle()).overlay(ZStack {
                                        Circle().inset(by:-1.09).fill(colr(k:"z").opacity(0.93)).brightness(-0.39*1.09)
                                        butv(kind:"rectangle.fill.on.rectangle.fill.circle", size:25.0, extr:[0.0, 0.0], iidx:87, clst:["b", "g", "b", "~"], pram:-1, actn:shms, actc:shmz)
                                            .brightness(0.09*1.39)
                                    }.offset(x:-19.99, y:-0.99))
                                }.offset(y:3.09)
                            }
                        }.frame(width:ssiz[0], height:ssiz[1])
                        .background() { ZStack {
                                let radi = 17.00
                                let iidx = idxs[1]
                                let kclr = clrs[iidx][2]
                                RoundedRectangle(cornerRadius:radi).inset(by:-0.99).fill(colr(k:"z"))
                                RoundedRectangle(cornerRadius:radi).inset(by:-3.99).stroke(colr(k:kclr), lineWidth:3.99).opacity(0.91)
                        } }.onContinuousHover { phase in
                            switch phase {
                            case .active:
                                sldr = [colr(k:"th"), colr(k:"bh"), colr(k:"th"), colr(k:"bh")]
                            case .ended:
                                DispatchQueue.main.asyncAfter(deadline:.now() + 0.39) {
                                    sldr = [colr(k:"t"), colr(k:"b"), colr(k:"th"), colr(k:"bh")]
                                }
                            }
                        }.gesture(WindowDragGesture())
                        Spacer(minLength:0.0)
                    }.frame(height:16.0).onTapGesture {
                        focu(0)
                    }
                    HStack {  }.padding(.leading, 24.0)
                    popv()
                }.padding(EdgeInsets(top:12.0, leading:0.0, bottom:40.0, trailing:0.0))
                colv()
                tobv()
                botv()
                moov()
                Spacer(minLength:0.0)
            }.background(bgfu(k:1))
        }.background(bgfu(k:0))
        .onAppear {
            print(Date(),"INFO","view","init")
            let _ = main()
            NSEvent.addLocalMonitorForEvents(matching:.systemDefined) { event in
                if (event.subtype.rawValue == 8) {
                    let kcode = ((event.data1 & 0xFFFF0000) >> 16)
                    let kflag = (event.data1 & 0x0000FFFF)
                    let kstat = ((((kflag & 0xFF00) >> 8)) == 10)
                    keye(keyc:Int32(kcode), keys:kstat)
                }
                return event
            }
            NSEvent.addLocalMonitorForEvents(matching:.keyDown) { event in
                if let _ = event.charactersIgnoringModifiers {
                    keyp(pres:event)
                }
                return event
            }
        }
    }

    func keye(keyc:Int32, keys:Bool) {
        if ((keyz != 0) && (keys == true)) {
            switch(keyc) {
            case NX_KEYTYPE_PLAY:
                bply(-1)
                break
            case NX_KEYTYPE_FAST:
                more(-1)
                break
            case NX_KEYTYPE_REWIND:
                prev(-1)
                break
            default:
                break
            }
            keyz = 1
        }
    }

    func colr(k:String) -> Color {
        var offs = 0.0
        if (wina[0] <= 60.0) { wina[0] = 97.0 }
        if (wina[3] <= 50.0) { wina[3] = 77.0 }
        if ((k.count > 1) && k.hasSuffix("h")) { offs = wina[2] }
        let cidx = (mods == 0) ? 1 : 0
        let alll = [
            [[0.13, 0.55, 0.87, 0.95], [0.19, 0.65, 0.99, 0.99]],
            [[0.91, 0.87, 0.71, 0.75], [0.87, 0.83, 0.67, 0.99]],
            [[0.91, 0.87, 0.71, 0.95], [0.09, 0.09, 0.09, 0.99]],
            [[0.91, 0.87, 0.71, wina[3]/100], [0.09, 0.09, 0.09, wina[3]/100]],
            [[0.91, 0.87, 0.71, 0.09], [0.87, 0.87, 0.75, 0.69]],
            [[0.17, 0.17, 0.17, wina[0]/100], [0.33, 0.33, 0.33, wina[0]/100]],
            [[0.17, 0.17, 0.17, 0.97], [0.33, 0.33, 0.33, 0.99]],
            [[0.13, 0.13, 0.13, 0.53], [0.97, 0.97, 0.97, 0.99]],
            [[0.35, 0.35, 0.35, 0.99], [0.99, 0.99, 0.99, 0.99]],
            [[0.91, 0.87, 0.71, 0.11], [0.87, 0.87, 0.75, 0.69]],
        ]
        var bcol = Color.init(red:alll[0][cidx][0]+offs, green:alll[0][cidx][1]+offs, blue:alll[0][cidx][2]+offs, opacity:alll[0][cidx][3])
        var gcol = Color.init(red:alll[1][cidx][0]+offs, green:alll[1][cidx][1]+offs, blue:alll[1][cidx][2]+offs, opacity:alll[1][cidx][3])
        var tcol = Color.init(red:alll[2][cidx][0]+offs, green:alll[2][cidx][1]+offs, blue:alll[2][cidx][2]+offs, opacity:alll[2][cidx][3])
        var lcol = Color.init(red:alll[3][cidx][0]+offs, green:alll[3][cidx][1]+offs, blue:alll[3][cidx][2]+offs, opacity:alll[3][cidx][3])
        var zcol = Color.init(red:alll[4][cidx][0]+offs, green:alll[4][cidx][1]+offs, blue:alll[4][cidx][2]+offs, opacity:alll[4][cidx][3])
        var acol = Color.init(red:alll[5][cidx][0]+offs, green:alll[5][cidx][1]+offs, blue:alll[5][cidx][2]+offs, opacity:alll[5][cidx][3])
        var scol = Color.init(red:alll[6][cidx][0]+offs, green:alll[6][cidx][1]+offs, blue:alll[6][cidx][2]+offs, opacity:alll[6][cidx][3])
        var wcol = Color.init(red:alll[7][cidx][0]+offs, green:alll[7][cidx][1]+offs, blue:alll[7][cidx][2]+offs, opacity:alll[7][cidx][3])
        var rcol = Color.init(red:alll[8][cidx][0]+offs, green:alll[8][cidx][1]+offs, blue:alll[8][cidx][2]+offs, opacity:alll[8][cidx][3])
        var ycol = Color.init(red:alll[9][cidx][0]+offs, green:alll[9][cidx][1]+offs, blue:alll[9][cidx][2]+offs, opacity:alll[9][cidx][3])
        if (clno[0][0] != 0.00) {
            let nsco = NSColor(clco[0])
            bcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (clno[1][0] != 0.00) {
            let nsco = NSColor(clco[1])
            gcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (clno[2][0] != 0.00) {
            let nsco = NSColor(clco[2])
            tcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
            lcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:wina[3]/100)
        }
        if (clno[3][0] != 0.00) {
            let nsco = NSColor(clco[3])
            zcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (clno[4][0] != 0.00) {
            let nsco = NSColor(clco[4])
            acol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:wina[0]/100)
            scol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (clno[5][0] != 0.00) {
            let nsco = NSColor(clco[5])
            wcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (clno[6][0] != 0.00) {
            let nsco = NSColor(clco[6])
            rcol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (clno[7][0] != 0.00) {
            let nsco = NSColor(clco[7])
            ycol = Color.init(red:nsco.redComponent+offs, green:nsco.greenComponent+offs, blue:nsco.blueComponent+offs, opacity:nsco.alphaComponent)
        }
        if (offs != 0.0) {
            ycol = ycol.opacity(0.69)
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
        if ((k == "y") || (k == "yh")) { return ycol }
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

    func bgfu(k:Int) -> AnyShapeStyle {
        let iidx = Int(wina[1])
        let noop = Color.clear
        let back = colr(k:"r")
        if (wina[0] <= 60.0) { wina[0] = 97.0 }
        if (k == 0) {
            if (iidx > 0) { return AnyShapeStyle(back.opacity(0.55)) }
            else { return AnyShapeStyle(noop) }
        } else {
            if let blur = winl[iidx] as? Material {
                return AnyShapeStyle(blur.opacity(wina[0]/100))
            }
            return AnyShapeStyle(winc)
        }
    }

    func main() {
        nobj.main()
        nobj.view_shuf = shuf;
        nobj.view_srtz = srtz;
        nobj.view_time[0] = nobj.form(inpt:0)
        nobj.view_time[1] = nobj.form(inpt:0)
        nobj.view_shuf[1] = false
        var i = 0
        for _ in clno {
            clco[i] = Color(red:clno[i][1], green:clno[i][2], blue:clno[i][3], opacity:clno[i][4])
            i += 1
        }
        nobj.view_tabb = nobj.view_tabb.main(nobj.view_tabl, colz:colu, ordr:cord, sizs:csiz, hist:chis)
        tabz = tabs(objc:$nobj.view_tabb, sees:$nobj.view_sees, sels:$nobj.view_sels, scro:$nobj.view_scro, srts:$nobj.view_srtz, refr:$refr)
        nobj.view_tabb.clrs.data_rows_type = rowl[rows]
        nobj.view_tabb.clrs.body_radi = 9.99
        refz()
        shma(1)
        focu(0)
    }

    func gets(kind:Int) -> String {
        nobj.glob().withLock {
            let hobj = nobj.geth()
            if (hobj != nil) {
                if (kind == 0) { return String(format:"%@", hobj!.song) }
                if (kind == 1) { return String(format:"%@ [%@]", hobj!.band, hobj!.genr) }
            } else {
                if (nobj.view_tabl.count < 1) {
                    if (kind == 0) { return "Loading Tracks" }
                    if (kind == 1) { return "Please Standby" }
                } else {
                    if (kind == 0) { return "Tracks Loaded" }
                    if (kind == 1) { return nobj.view_tabl.count.formatted() }
                }
            }
            return " "
        }
    }

    func plyz() -> Int {
        if (mode == "play.circle") { return 0 }
        return 1
    }

    func plyi() -> String {
        if (plyz() == 0) { return "play.circle" }
        return "pause.circle"
    }

    func symb(r:Int) {
        mode = (r == 0) ? "play.circle" : "pause.circle"
        let jidx = plyz()
        let idxl = [0, 1, 5]
        for idxi in idxl {
            let iidx = idxs[idxi]
            clrs[iidx][2] = (clrs[iidx][jidx] + clrs[iidx][5])
        }
        imgl = 0
    }

    func play(objc:mdat, over:Int) -> Int {
        let chks = nobj.gets()
        var r = 0
        if ((chks != 1) || (over == 1)) {
            if (nobj.pobj == nil) {
                r = nobj.play(mobj:objc, over:1)
            } else {
                r = nobj.play(mobj:nil, over:1)
            }
        } else {
            r = nobj.stop()
        }
        symb(r:r)
        keyz = r
        return r
   }

    func seek(when:Int64) {
        if (nobj.tabp.count > 0) {
            let cobj = nobj.plyr.currentTime()
            let csec = nobj.divs(a:Int64(cobj.value), b:Int64(cobj.timescale))
            nobj.plyr.seek(to:CMTime(seconds:Double(csec+when), preferredTimescale:CMTimeScale(1)))
        }
    }

    func ffwd(_ args:Int) {
        if (nobj.tabp.count > 0) {
            seek(when:10)
        }
    }

    func frev(_ args:Int) {
        if (nobj.tabp.count > 0) {
            seek(when:-10)
        }
    }

    func more(_ args:Int) {
        if (nobj.tabp.count > 0) {
            let r = nobj.next(iidx:1, over:0)
            symb(r:r)
        }
    }

    func prev(_ args:Int) {
        var i = -1
        let l = nobj.view_time[0].components(separatedBy:":")
        if (l.count > 1) {
            let n = Int(l[1])
            if ((n != nil) && (n! >= 5)) { i = 0 }
        }
        if (nobj.tabp.count > 0) {
            let r = nobj.next(iidx:i, over:0)
            symb(r:r)
        }
    }

    func bply(_ args:Int) {
        if (nobj.tabp.count > 0) {
            var iidx = 0
            let hobj = nobj.geth()
            if (hobj != nil) { iidx = (nobj.indx % nobj.tabp.count) }
            let _ = play(objc:nobj.tabp[iidx], over:0)
        }
    }

    func star(_ args:Int) {
        nobj.glob().withLock {
            let hobj = nobj.geth()
            if (hobj != nil) {
                nobj.view_sels = hobj!.id
                nobj.view_scro = hobj!.id
                nobj.view_tabb.iscr += 1
            }
        }
    }

    func fndr(_ args:Int) {
        if (nobj.view_sels != nil) {
            for item in nobj.view_tabl {
                if (item.id == nobj.view_sels!) {
                    let urlp = URL(fileURLWithPath:item.path)
                    NSWorkspace.shared.activateFileViewerSelecting([urlp])
                }
            }
        }
    }

    func filt() {
        let iidx = idxs[2]
        let nows = 1970.time()
        if (nobj.view_srch == "") {
            clrs[iidx][2] = clrs[iidx][0]
            usee(9)
        } else {
            clrs[iidx][2] = clrs[iidx][1]
        }
        if ((nows - last) <= 1) {
            DispatchQueue.main.asyncAfter(deadline:.now() + 0.50) { filt() }
        } else if (nobj.view_baup.count > 0) {
            if (nobj.view_srch != "") {
                do {
                    let regx = try Regex("^.*"+nobj.view_srch+".*$").ignoresCase()
                    var temp = [] as [mdat]
                    for item in nobj.view_baup {
                        if let _ = item.hash.wholeMatch(of:regx) {
                            temp.append(item)
                        }
                    }
                    if ((-1 < pidx) && (pidx < plst.count)) {
                        let gsrt = nobj.gens(inpt:plst[pidx][2])
                        temp.sort(using:gsrt)
                    }
                    nobj.glob().withLock {
                        nobj.view_tabl = temp
                        nobj.view_refl += 1
                    }
                } catch {
                    /* no-op */
                }
            } else {
                nobj.glob().withLock {
                    nobj.view_tabl = nobj.view_baup
                    nobj.view_refl += 1
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

    func shma(_ mode:Int) {
        let dely = 0.01
        if (shwm == true) {
            if let wind = NSApp.windows.first {
                if (mode != 1) {
                    winz = [Int(wind.frame.origin.x), Int(wind.frame.origin.y), Int(wind.frame.width), Int(wind.frame.height)]
                }
                if ((winz[2] > 50) && (winz[3] > 50)) {
                    let ssiz = [915, 125]
                    var temp = [winz[0], winz[1]+(winz[3]-ssiz[1]), ssiz[0], ssiz[1]]
                    if ((wini[2] > 50) && (wini[3] > 50)) {
                        temp = [wini[0], wini[1], ssiz[0], ssiz[1]]
                    }
                    DispatchQueue.main.asyncAfter(deadline:.now() + dely) {
                        wind.styleMask.remove(.resizable)
                        wind.setFrame(NSRect(x:temp[0], y:temp[1], width:temp[2], height:temp[3]), display:true)
                    }
                }
            }
        } else {
            if let wind = NSApp.windows.first {
                if (mode != 1) {
                    wini = [Int(wind.frame.origin.x), Int(wind.frame.origin.y), Int(wind.frame.width), Int(wind.frame.height)]
                }
                if ((winz[2] > 50) && (winz[3] > 50)) {
                    wind.setFrame(NSRect(x:winz[0], y:winz[1], width:winz[2], height:winz[3]), display:true)
                    wind.styleMask.insert(.resizable)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline:.now() + dely) {
            nobj.view_rotf += 1
            refr = UUID()
        }
    }

    func shms(_ args:Int) {
        if (shwm == false) { shwm = true }
        else { shwm = false }
    }

    func shmz() -> Int {
        if (shwm == false) { return 0 }
        return 1
    }

    func shfz() -> Int {
        if ((nobj.view_shuf[0] == false) && (nobj.view_shuf[1] == false)) { return 0 }
        return 1
    }

    func mutz() -> Int {
        if (mute == false) { return 0 }
        return 1
    }

    func muti() -> String {
        if (mutz() == 0) { return "speaker.circle" }
        return "speaker.slash.circle"
    }

    func fswz() -> Int {
        if (shwp == false) { return 0 }
        return 1
    }

    func fswi() -> String {
        if (fswz() == 0) { return "plus.circle" }
        return "minus.circle"
    }

    func fswa(_ args:Int) {
        shws = false
        if (shwp == false) { shwp = true }
        else { shwp = false }
    }

    func fssz() -> Int {
        if (shws == false) { return 0 }
        return 1
    }

    func fssi() -> String {
        if (fssz() == 0) { return "gearshape.circle" }
        return "gearshape.circle" //minus.circle"
    }

    func fssa(_ args:Int) {
        shwp = false
        shwa = false
        if (shws == false) { shws = true }
        else { shws = false }
    }

    func fscz() -> Int {
        if (shwc == false) { return 0 }
        return 1
    }

    func fsci() -> String {
        if (fscz() == 0) { return "line.3.horizontal.circle" }
        return "line.3.horizontal.circle" //"minus.circle"
    }

    func fsca(_ args:Int) {
        if (shwc == false) { shwc = true }
        else { shwc = false }
    }

    func fsbz() -> Int {
        if (shwb == false) { return 0 }
        return 1
    }

    func fsbi() -> String {
        if (fsbz() == 0) { return "ellipsis.circle" }
        return "ellipsis.circle" //"minus.circle"
    }

    func fsba(_ args:Int) {
        shws = false
        if (shwb == false) { shwb = true }
        else { shwb = false }
    }

    func fsaz() -> Int {
        if (shwa == false) { return 0 }
        return 1
    }

    func fsai() -> String {
        if (fsaz() == 0) { return "photo.circle" }
        return "photo.circle" //"minus.circle"
    }

    func fsaa(_ args:Int) {
        shws = false
        if (shwa == false) { shwa = true }
        else { shwa = false }
    }

    func moov() -> AnyView {
        var vobj = AnyView(HStack {
            /* no-op */
        }.onChange(of:shwm) {
            shma(-1)
        })
        if (shwm == true) {
            vobj = AnyView(HStack {
                /* no-op */
            }.onChange(of:shwm) {
                shma(-1)
            })
        }
        return vobj
    }

    func popv() -> AnyView {
        var vobj = AnyView(EmptyView())
        if (shwm == false) {
            vobj = AnyView(HStack {
                HStack {  }.padding(.leading, 4.0)
                VStack {
                    let epad = 8.0
                    let offs = 0.05
                    let spcr = 1.55
                    HStack {
                        if (shwb == false) {
                            HStack {
                                let iidx = idxs[2]
                                TextField("Filter", text:$nobj.view_srch).showClearButton($nobj.view_srch)
                                    .onAppear {
                                        fals = false
                                        fobo = false
                                    }.onChange(of:nobj.view_srch) { olds, vals in
                                        last = 1970.time()
                                        filt()
                                    }
                                    .disabled(fals)
                                    .defaultFocus($fobo, false).focused($fobo, equals:true).focusable(fobo, interactions:.activate).focusEffectDisabled()
                                    .foregroundColor(colr(k:"t"))
                                    .disableAutocorrection(true)
                                    .textFieldStyle(.plain)
                                    .font(Font.custom("Menlo", size:15.0).weight(.bold))
                                    .padding(EdgeInsets(top:1.5, leading:12.0, bottom:1.5, trailing:24.0))
                                    .overlay(RoundedRectangle(cornerRadius:13.0).inset(by:-5.0).stroke(colr(k:clrs[iidx][2]), lineWidth:3.0))
                            }.offset(x:3.99)
                        } else {
                            HStack {
                                Color.clear.frame(height:1.0).contentShape(Rectangle()).overlay(ZStack {
                                    RoundedRectangle(cornerRadius:19.0).stroke(colr(k:"b"), lineWidth:3.00)
                                    //RoundedRectangle(cornerRadius:19.0).inset(by:1.99).fill(colr(k:"s"))
                                    VStack {
                                        HStack {
                                            Spacer()
                                            butv(kind:fsai(), size:26.0, extr:[epad*spcr, 0.0], iidx:27, clst:["b", "g", "b", "~"], pram:-1, actn:fsaa, actc:fsaz)
                                            butv(kind:fssi(), size:26.0, extr:[epad*spcr, 0.0], iidx:25, clst:["b", "g", "b", "~"], pram:-1, actn:fssa, actc:fssz)
                                        }.padding(.trailing, 1.0)
                                        Spacer()
                                    }.offset(x:-13.99, y:7.99)
                                }.padding(.trailing, -11.0).frame(height:85.0).offset(x:3.00, y:21.00+offs))

                            }.offset(x:-3.99, y:-1.99)
                        }
                        butv(kind:fswi(), size:30.0, extr:[0.0, 0.0], iidx:idxs[4], clst:["b", "g", "b", "~"], pram:-1, actn:fswa, actc:fswz).offset(x:12.0).overlay(
                            butv(kind:"multiply.circle", size:26.0, extr:[0.0, 0.0], iidx:5, clst:["b", "g", "b", "!"], pram:1, actn:usee, actc:niln)
                                .padding(.trailing, 1.0).padding(.top, 1.0).offset(x:13.00, y:39.00)
                        )
                    }.frame(width:240.0).offset(x:0.09, y:offs)
                    HStack {  }.overlay(
                        HStack {
                            butv(kind:"asterisk.circle", size:26.0, extr:[epad*spcr, 0.0], iidx:6, clst:["b", "g", "b", "!"], pram:-1, actn:star, actc:niln)
                            butv(kind:"viewfinder.circle", size:26.0, extr:[epad*spcr, 0.0], iidx:7, clst:["b", "g", "b", "!"], pram:-1, actn:fndr, actc:niln)
                            butv(kind:fsci(), size:26.0, extr:[epad*spcr, 0.0], iidx:8, clst:["b", "g", "b", "~"], pram:-1, actn:fsca, actc:fscz)
                            butv(kind:fsbi(), size:26.0, extr:[epad*spcr, 0.0], iidx:9, clst:["b", "g", "b", "~"], pram:-1, actn:fsba, actc:fsbz)
                        }.frame(width:1.0, height:1.0).offset(x:-11.00, y:25.00+offs)
                    )
                }.offset(x:0.09, y:-17.99)
                HStack {  }.padding(.leading, 36.0)
            })
        }
        return vobj
    }

    func colv() -> AnyView {
        var vobj = AnyView(EmptyView())
        if ((shwc == true) && (shwm == false)) {
            vobj = AnyView(HStack {
                ZStack {
                    HStack {
                        Table(nobj.view_coad, selection:$coas) {
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
                                    for item in nobj.view_coad {
                                        if (item.id == vals.first) {
                                            if (item.band != "---") {
                                                for elem in nobj.view_cobd {
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
                                if (flag == 1) { nobj.view_cobt = temp ; nobj.view_cobt.insert(contentsOf:[nobj.view_cobd[0]], at:0) }
                                else { nobj.view_cobt = nobj.view_cobd }
                                if (objc != nil) { help(kind:0, colv:objc!.band) }
                            }
                        Table(nobj.view_cobt, selection:$cobs) {
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
                                    for item in nobj.view_cobt {
                                        if (item.id == vals.first) {
                                            if (item.albm != "---") {
                                                for elem in nobj.view_baup {
                                                    if ((elem.band == item.band) && (elem.albm == item.albm)) {
                                                        if (!(uniq.contains(elem.genr))) {
                                                            temp.append(elem)
                                                            uniq.append(elem.genr)
                                                        }
                                                    }
                                                }
                                                flag = 1
                                            } else {
                                                if (nobj.view_cobt.count > 1) {
                                                    for elem in nobj.view_baup {
                                                        if (elem.band == nobj.view_cobt[1].band) {
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
                                if (flag == 1) { nobj.view_coct = temp ; nobj.view_coct.insert(contentsOf:[nobj.view_cocd[0]], at:0) }
                                else { nobj.view_coct = nobj.view_cocd }
                                if (objc != nil) { help(kind:1, colv:objc!.albm) }
                            }
                        Table(nobj.view_coct, selection:$cocs) {
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
                                    for item in nobj.view_coct {
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

    func tobv() -> AnyView {
        var vobj = AnyView(EmptyView())
        if (shwm == false) {
            vobj = AnyView(HStack {
                if let tabo = tabz {
                    tabo.onAppear {
                        let _ = tabo.cola({ c, r, v, k, w, z, s, e in
                            if ((c == 0) || (r == 0)) {
                                let u = UUID(uuidString:v)
                                var n = "circle.dotted"
                                var l = 17.0
                                if ((u != nil) && (s != nil) && (u! == s!)) {
                                    n = "asterisk.circle"
                                    l = 19.0
                                }
                                return AnyView(VStack(spacing:0) {
                                    Spacer()
                                    HStack {
                                        txtv(strs:" ", size:9.0, colr:z, kind:1, bold:1).overlay(ZStack {
                                            HStack {
                                                if (r == 0) {
                                                    Image(systemName:n).resizable().scaledToFit().frame(width:l, height:l).foregroundColor(z).offset(x:5.0)
                                                }
                                            }
                                        }.zIndex(9.0))
                                    }
                                    Spacer()
                                })
                            }
                            if ((c > 0) || (r > 0)) {
                                let sizw = (w + e)
                                let clst = [5, 6, 7]
                                let alin = (clst.contains(c) || clst.contains(r)) ? 0 : 1
                                let kind = ((c > 0) || clst.contains(c) || clst.contains(r)) ? 1 : 0
                                let bold = (kind == 1) ? 1 : 0
                                var size = (r > 0) ? 13.0 : 15.0
                                let offw = ((c > 0) && (alin == 0)) ? -1.19 * e : 0.00
                                if (clst.contains(r)) { size = (size - 0.99) }
                                return AnyView(VStack(spacing:0) {
                                    Spacer()
                                    HStack {
                                        txtv(strs:" ", size:11.0, colr:z, kind:1, bold:1).frame(width:sizw).overlay(ZStack {
                                            HStack {
                                                txtv(strs:v, size:size, colr:z, kind:kind, bold:bold).frame(width:sizw, alignment:(alin == 0) ? .center : .leading).offset(x:offw).overlay(ZStack {
                                                    HStack {
                                                        if (c > 0) {
                                                            if (e > 0.0) {
                                                                let n = (!(nobj.view_srtz.lowercased().contains("reverse"))) ? "chevups.png" : "chevdos.png"
                                                                let i = NSImage(named:n)
                                                                Spacer()
                                                                Image(nsImage:i!).resizable().renderingMode(.template).scaledToFit().frame(width:19.00, height:19.00).foregroundColor(z).offset(x:(e/1.99), y:-0.69)
                                                            }
                                                        }
                                                    }
                                                })
                                            }.onContinuousHover { phase in
                                                if (c > 0) {
                                                    switch phase {
                                                    case .active:
                                                        if (nobj.view_tabb.clrs.head_high_indx != c) { nobj.view_tabb.clrs.head_high_indx = c }
                                                    case .ended:
                                                        nobj.view_tabb.clrs.head_high_indx = -1
                                                    }
                                                }
                                            }
                                        })
                                    }
                                    Spacer()
                                })
                            }
                            return AnyView(EmptyView())
                        }).pact({
                            var iidx = 0
                            for item in nobj.view_baup {
                                if ((nobj.view_sels != nil) && (nobj.view_sels! == item.id)) {
                                    nobj.halt()
                                    nobj.indx = iidx
                                    bply(-1)
                                }
                                iidx += 1
                            }
                        })
                    }.onChange(of:nobj.view_refl) {
                        let _ = tabo.load(nobj.view_tabl, iden:\mdat.id, colz:colu)
                    }.onChange(of:nobj.view_sees) {
                        refr = UUID()
                    }.onChange(of:nobj.view_sels) {
                        refr = UUID()
                    }.onChange(of:nobj.view_scro) {
                        refr = UUID()
                    }.onChange(of:nobj.view_srtz) {
                        nobj.glob().withLock {
                            if (pidx < 0) {
                                nobj.view_srts = nobj.gens(inpt:nobj.view_srtz)
                                nobj.view_baup.sort(using:nobj.view_srts)
                                if (nobj.view_srch == "") { nobj.view_tabl = nobj.view_baup }
                                nobj.sync(inpt:nobj.view_baup)
                            } else {
                                if ((-1 < pidx) && (pidx < plst.count)) {
                                    plst[pidx][4] = nobj.view_srtz
                                }
                            }
                            srtz = nobj.view_srtz
                            refr = UUID()
                        }
                    }.onChange(of:nobj.view_tabb.cols.ordr) {
                        cord = nobj.view_tabb.cols.ordr
                    }.onChange(of:nobj.view_tabb.cols.sizs) {
                        csiz = nobj.view_tabb.cols.sizs
                    }.onChange(of:nobj.view_tabb.cols.hist) {
                        chis = nobj.view_tabb.cols.hist
                    }.frame(minHeight:400.0)
                    .focused($isfo).focusable().focusEffectDisabled()
                    .padding(EdgeInsets(top:-7.9, leading:11.0, bottom:11.0, trailing:11.0))
                    .zIndex(1.0)
                    .overlay(pref())
                    .overlay(panv())
                    .overlay(pana())
                }
            })
        }
        return vobj
    }

    func botv() -> AnyView {
        var vobj = AnyView(EmptyView())
        if (shwm == false) {
            vobj = AnyView(HStack {
                HStack {
                    HStack {
                        HStack {
                            Spacer()
                            let snum = (nobj.view_tabl.count > 0) ? nobj.view_tabl.count : nobj.plen
                            let stts = snum.formatted().replacingOccurrences(of:",", with:",")
                            let strv = String(format:"%@  Tracks", stts)
                            txtv(strs:strv, size:15.0, colr:colr(k:"t"), kind:3, bold:0)
                        }.frame(maxWidth:.infinity).offset(y:0.09)
                        HStack {
                            /*Rectangle().frame(width:1.0, height:1.0).foregroundColor(noco())
                             .overlay(RoundedRectangle(cornerRadius:1.0).frame(width:1.9, height:19.0).foregroundColor(colr(k:"t"))*/
                            if let imgo = imgs(mode:1) {
                                Rectangle().frame(width:1.0, height:1.0).foregroundColor(noco()).padding(EdgeInsets(top:0.0, leading:19.0, bottom:0.0, trailing:19.0)).overlay(
                                    imgo.resizable().frame(width:45.0, height:45.0).opacity(0.75)
                                        .rotationEffect(.degrees(nobj.view_rota)).onChange(of:nobj.view_rotf) {
                                            if ((nobj.view_rotf % 2) != 0) {
                                                withAnimation(.linear(duration:1).speed(0.15).repeatForever(autoreverses:false)) {
                                                    nobj.view_rota = 360.0
                                                }
                                            } else {
                                                withAnimation(.linear(duration:0)) {
                                                    nobj.view_rota = 0.0
                                                }
                                            }
                                        })
                            }
                        }.padding(EdgeInsets(top:0.0, leading:11.0, bottom:0.0, trailing:11.0)).offset(y:-1.99)
                        HStack {
                            let strv = String(format:"TurnTable  %@", String().version())
                            txtv(strs:strv, size:15.0, colr:colr(k:"t"), kind:3, bold:0)
                            Spacer()
                        }.frame(maxWidth:.infinity).offset(y:0.09)
                    }.offset(x:-7.99, y:-7.99)
                    HStack {
                        Rectangle().frame(width:1.0, height:37.99).foregroundColor(noco()).overlay(ProgressView().scaleEffect(x:0.69, y:0.69, anchor:.center).offset(x:-25.99, y:-7.99))
                    }.opacity(nobj.view_opap)
                }.onHover { over in
                    let iidx = idxs[4]
                    shwp = false
                    clrs[iidx][2] = (clrs[iidx][0] + clrs[iidx][5])
                }
            })
        }
        return vobj
    }

    func pana() -> AnyView {
        var vobj = AnyView(EmptyView())
        if (shwa == true) {
            let size = 192.0
            let smol = 48.0
            let bpad = 64.0
            let tpad = (shwp == false) ? 55.0 : 256.0 + 42.0
            let rads = 17.0
            let zclr = "g"
            vobj = AnyView(
                ZStack {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack {
                                RoundedRectangle(cornerRadius:rads).inset(by:-1.0)
                                    .stroke(colr(k:zclr), lineWidth:2.33)
                                    .overlay(
                                        VStack {
                                            VStack {
                                                if let hold = nobj.geth() {
                                                    //let cidx = (Int(hold.covr) != nil) ? Int(hold.covr)! : -1
                                                    //let temp = ((-1 < cidx) && (cidx < nobj.imgs.count)) ? nobj.imgs[cidx].data(using:.utf8) : Data()
                                                    if (hold.path != nobj.view_covr[0]) {
                                                        let _ = nobj.meta(iidx:-1, path:hold.path)
                                                    }
                                                }
                                                if let imgo = aart {
                                                    imgo.resizable().frame(maxWidth:.infinity, maxHeight:.infinity)
                                                } else if let imgo = imgs(mode:2) {
                                                    imgo.resizable().frame(width:size-smol, height:size-smol)
                                                }
                                            }.onChange(of:nobj.view_covr) {
                                                let temp = nobj.view_covr[1].data(using:.utf8)
                                                if let data = Data(base64Encoded:temp!) {
                                                    if let nimg = NSImage(data:data) {
                                                        aart = Image(nsImage:nimg)
                                                    } else { aart = nil }
                                                } else { aart = nil }
                                            }
                                        }.frame(maxWidth:.infinity, maxHeight:.infinity).background(colr(k:"s")).cornerRadius(rads)
                                    )
                            }.frame(width:size, height:size).padding(.bottom, bpad).padding(.trailing, tpad)
                        }
                    }
                }.zIndex(77.0)
            )
        }
        return vobj
    }

    func panv() -> AnyView {
        var vobj = AnyView(EmptyView())
        if (shwp == true) {
            //let side = [0.0, 0.0, 0.0]
            let side = [65.0, 105.0, 11.0]
            let wide = 256.0
            let tpad = 45.0
            let bpad = 75.0
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
                                                            let iidx = idxs[3]
                                                            Spacer()
                                                            TextField("Playlist", text:$name).showClearButton($name)
                                                                .onAppear {
                                                                    pobo = false
                                                                }.onChange(of:name) { olds, vals in
                                                                    if (name == "") {
                                                                        clrs[iidx][2] = clrs[iidx][0]
                                                                        usee(8)
                                                                    } else {
                                                                        clrs[iidx][2] = clrs[iidx][1]
                                                                    }
                                                                }
                                                                .defaultFocus($pobo, false).focused($pobo, equals:true).focusable(pobo, interactions:.activate).focusEffectDisabled()
                                                                .frame(width:128.0)
                                                                .foregroundColor(colr(k:"t"))
                                                                .disableAutocorrection(true)
                                                                .textFieldStyle(.plain)
                                                                .font(Font.custom("Menlo", size:13.0).weight(.bold))
                                                                .padding(EdgeInsets(top:1.5, leading:12.0, bottom:1.5, trailing:24.0))
                                                                .overlay(RoundedRectangle(cornerRadius:9.0).inset(by:-3.5).stroke(colr(k:clrs[iidx][2]), lineWidth:3.0))
                                                                .offset(x:3.0, y:0.5)
                                                            Rectangle().foregroundColor(noco()).frame(width:1.0, height:1.0)
                                                            butv(kind:"plus.circle", size:24.0, extr:[0.0, 0.0], iidx:11, clst:["b", "g", "b", "!"], pram:-1, actn:padd, actc:niln)
                                                            Rectangle().foregroundColor(noco()).frame(width:5.9, height:1.0)
                                                        }
                                                        HStack {
                                                            butv(kind:"a.circle", size:20.0, extr:[0.0, 0.0], iidx:16, clst:["fa", "g", "fa", "!"], pram:0, actn:helb, actc:niln)
                                                            butv(kind:"b.circle", size:20.0, extr:[0.0, 0.0], iidx:17, clst:["fb", "g", "fb", "!"], pram:1, actn:helb, actc:niln)
                                                            butv(kind:"g.circle", size:20.0, extr:[0.0, 0.0], iidx:18, clst:["fg", "g", "fg", "!"], pram:2, actn:helb, actc:niln)
                                                            butv(kind:"y.circle", size:20.0, extr:[0.0, 0.0], iidx:19, clst:["fo", "g", "fo", "!"], pram:3, actn:helb, actc:niln)
                                                        }.padding(EdgeInsets(top:4.0, leading:0.0, bottom:16.0, trailing:0.0))
                                                        List {
                                                            ForEach(0..<plst.count, id:\.self) { i in
                                                                HStack {
                                                                    txtv(strs:plst[i][0], size:15.0, colr:colr(k:"t"), kind:0, bold:0).padding(.leading, 8.0)
                                                                    Spacer()
                                                                    butv(kind:"pencil.circle", size:20.0, extr:[0.0, 0.0], iidx:300+i, clst:["b", "g", "b", "!"], pram:i, actn:pedt, actc:niln)
                                                                    butv(kind:"multiply.circle", size:20.0, extr:[0.0, 0.0], iidx:500+i, clst:["b", "g", "b", "!"], pram:i, actn:pdel, actc:niln)
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
                                }.frame(width:wide+side[0]).offset(x:-45.0+side[1], y:tpad)
                            }
                            Spacer()
                        }
                        if (side[0] != 0.0) {
                            ZStack { Rectangle().frame(width:1.0).foregroundColor(noco()).overlay(
                                RoundedRectangle(cornerRadius:9.0).frame(width:45.0).frame(maxHeight:.infinity)
                                    .padding(EdgeInsets(top:25.0, leading:0.0, bottom:25.0, trailing:0.0)).offset(x:side[2], y:-5.0)
                                    .foregroundColor(colr(k:"s"))
                            ) }.zIndex(55.0)
                        }
                    }
                }.zIndex(33.0)
            )
        }
        return vobj
    }

    func pref() -> AnyView {
        var vobj = AnyView(EmptyView())
        if (shws == true) {
            let side = [0.0, 0.0, 0.0]
            let tpad = 45.0
            let bpad = 75.0
            let wpad = 80.0
            let rads = 17.0
            let maxh = 75.0
            let maxw = 115.0
            let spcb = 8.0
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
                                                        }.padding(.bottom, 28.0)
                                                        HStack {
                                                            VStack {
                                                                Spacer()
                                                                HStack {
                                                                    txtv(strs:"Colors", size:15.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Text(" ")
                                                                    butv(kind:"multiply.circle", size:20.0, extr:[0.0, 0.0], iidx:91, clst:["b", "g", "b", "~"], pram:-1, actn:nilz, actc:nilc)
                                                                    Spacer()
                                                                }
                                                                Spacer()
                                                            }.frame(maxWidth:maxw).frame(maxHeight:maxh)
                                                            Text(" ")
                                                            Text(" ")
                                                            VStack {
                                                                Spacer()
                                                                let clst = ["Base", "High", "Text", "Tint", "View", "List", "Blur", "Head"]
                                                                let numr = 2
                                                                let half = ((clst.count/numr)+(clst.count%numr))
                                                                ForEach(0..<numr, id:\.self) { j in
                                                                    HStack {
                                                                        ForEach(0..<half, id:\.self) { i in
                                                                            let iidx = ((j * half) + i)
                                                                            if (iidx < clst.count) {
                                                                                txtv(strs:clst[iidx], size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                                ColorPicker("", selection:$clco[iidx]).onChange(of:clco[iidx]) {
                                                                                    let temp = NSColor(clco[iidx])
                                                                                    clno[iidx] = [temp.alphaComponent, temp.redComponent, temp.greenComponent, temp.blueComponent, temp.alphaComponent]
                                                                                    refz()
                                                                                }
                                                                                Text(" ")
                                                                            }
                                                                        }
                                                                        Spacer()
                                                                    }
                                                                }
                                                                Spacer()
                                                            }.frame(maxHeight:maxh)
                                                            Spacer()
                                                        }.padding(.bottom, spcb)
                                                        HStack {
                                                            var nice = round(wina[2] * 100)
                                                            VStack {
                                                                Spacer()
                                                                HStack {
                                                                    txtv(strs:"Window", size:15.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Text(" ")
                                                                    butv(kind:"multiply.circle", size:20.0, extr:[0.0, 0.0], iidx:90, clst:["b", "g", "b", "!"], pram:-1, actn:zilw, actc:niln)
                                                                    Spacer()
                                                                }
                                                                Spacer()
                                                            }.frame(maxWidth:maxw).frame(maxHeight:maxh)
                                                            Text(" ")
                                                            Text(" ")
                                                            VStack {
                                                                Spacer()
                                                                HStack {
                                                                    txtv(strs:"View", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Text(" ")
                                                                    Slider(value:$wina[0], in:69...99, step:1).frame(width:128.0).onChange(of:wina[0]) {
                                                                        winc = colr(k:"a")
                                                                        wins = 1
                                                                    }
                                                                    txtv(strs:"\(Int(wina[0]))", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Text(" ")
                                                                    Text(" ")
                                                                    txtv(strs:"Blur", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Text(" ")
                                                                    Slider(value:$wina[1], in:0...5, step:1).frame(width:128.0).onChange(of:wina[1]) {
                                                                        wins = 2
                                                                    }
                                                                    Spacer()
                                                                }
                                                                HStack {
                                                                    txtv(strs:"Text", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Text(" ")
                                                                    Slider(value:$wina[3], in:59...89, step:1).frame(width:128.0).onChange(of:wina[3]) {
                                                                        wins = 4
                                                                        refz()
                                                                    }
                                                                    txtv(strs:"\(Int(wina[3]))", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Text(" ")
                                                                    Text(" ")
                                                                    txtv(strs:"Hover", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Text(" ")
                                                                    Slider(value:$wina[2], in:-0.19...0.19, step:0.001).frame(width:128.0).onChange(of:wina[2]) {
                                                                        nice = round(wina[2] * 100)
                                                                        wina[2] = (Double(nice) / 100)
                                                                        wins = 3
                                                                    }
                                                                    let outs = String(format:"%@0.%02d", (nice < 0.0) ? "-" : "+", Int(abs(nice)))
                                                                    txtv(strs:"\(outs)", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Spacer()
                                                                }
                                                                Spacer()
                                                            }.frame(maxHeight:maxh)
                                                            Spacer()
                                                        }.padding(.bottom, spcb)
                                                        HStack {
                                                            VStack {
                                                                Spacer()
                                                                HStack {
                                                                    txtv(strs:"Theme", size:15.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Spacer()
                                                                }
                                                                Spacer()
                                                            }.frame(maxWidth:maxw).frame(maxHeight:maxh)
                                                            Text(" ")
                                                            Text(" ")
                                                            VStack {
                                                                Spacer()
                                                                HStack {
                                                                    txtv(strs:"List", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Text(" ")
                                                                    Picker(selection:$rows, label:Text("")) {
                                                                        ForEach(0..<rowl.count, id:\.self) {
                                                                            Text(rowl[$0].capitalized)
                                                                        }
                                                                    }.pickerStyle(.segmented).frame(width:128.0).offset(x:-9.99)
                                                                        .onChange(of:rows) {
                                                                            nobj.view_tabb.clrs.data_rows_type = rowl[rows]
                                                                        }
                                                                    Text(" ")
                                                                    Text(" ")
                                                                    txtv(strs:"Mode", size:13.0, colr:colr(k:"t"), kind:0, bold:1)
                                                                    Text(" ")
                                                                    Picker(selection:$mods, label:Text("")) {
                                                                        ForEach(0..<styl.count, id:\.self) {
                                                                            Text(styl[$0].capitalized)
                                                                        }
                                                                    }.pickerStyle(.segmented).frame(width:128.0).offset(x:-9.99)
                                                                        .onChange(of:mods) {
                                                                            refz()
                                                                        }
                                                                    Spacer()
                                                                }
                                                                Spacer()
                                                            }.frame(maxHeight:maxh)
                                                            Spacer()
                                                        }.padding(.bottom, spcb)
                                                        Spacer()
                                                    }.padding(.leading, 16.0)
                                                    Spacer()
                                                }.frame(maxWidth:.infinity, maxHeight:.infinity).padding(.top, 12.0).padding(.trailing, side[0]).background(colr(k:"s")).cornerRadius(rads)
                                            )
                                        Rectangle().foregroundColor(noco()).frame(width:1.0, height:bpad)
                                    }
                                }.padding(.leading, 89.0+wpad).offset(x:-45.0+side[1], y:tpad)
                            }
                            Spacer()
                        }
                    }
                }.zIndex(11.0)
            )
        }
        return vobj
    }

    func padd(_ args:Int) {
        if ((nobj.view_srch != "") && (name != "")) {
            plst.append([name, nobj.view_srch, "f", "name"])
        }
    }

    func pdel(_ iidx:Int) {
        if ((-1 < iidx) && (iidx < plst.count)) {
            plst.remove(at:iidx)
            usee(7)
        }
    }

    func pedt(_ iidx:Int) {
        if ((nobj.view_srch != "") && (name != "")) {
            if ((-1 < iidx) && (iidx < plst.count)) {
                if (plst[iidx].count < 3) { plst[iidx].append("f") }
                if (plst[iidx].count < 4) { plst[iidx].append("name") }
                plst[iidx][0] = name
                plst[iidx][1] = nobj.view_srch
            }
        }
    }

    func psel(iidx:Int) {
        if ((-1 < iidx) && (iidx < plst.count)) {
            if (plst[iidx].count < 3) { plst[iidx].append("f") }
            if (plst[iidx].count < 4) { plst[iidx].append("name") }
            pidx = iidx
            name = plst[pidx][0]
            nobj.view_srch = plst[pidx][1]
            if (plst[pidx][2] == "f") { nobj.view_shuf[1] = false }
            else { nobj.view_shuf[1] = true }
        }
    }

    func pcol(iidx:Int) -> Color {
        if ((nobj.view_srch != "") && (name != "")) {
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
            nobj.view_sels = nil
        } else if (nobj.view_sels != nil) {
            for item in nobj.view_baup {
                if (item.id == nobj.view_sels!) {
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
        nobj.view_srch = regx
    }

    func helb(_ kind:Int) {
        help(kind:kind, colv:"")
    }

    func focu(_ mode:Int) {
        if (mode == 0) { isfo = true ; fobo = false ; pobo = false }
        if (mode == 1) { isfo = false ; fobo = true ; pobo = false }
        if (mode == 2) { isfo = false ; fobo = false ; pobo = true }
    }

    func usee(_ mode:Int) {
        focu(0)
        coas.removeAll()
        cobs.removeAll()
        cocs.removeAll()
        nobj.view_srch = ""
        name = ""
        wini = [0, 0, 0, 0]
        if (mode >= 5) {
            nobj.view_shuf[1] = false
            if (pidx > -1) {
                let gsrt = nobj.gens(inpt:nobj.view_srtz)
                nobj.glob().withLock {
                    nobj.view_tabl.sort(using:gsrt)
                }
                pidx = -1
            }
        } else {
            nobj.view_sels = nil
            nobj.view_scro = nil
        }
    }

    func shfs(_ args:Int) {
        var iidx = 0
        if (pidx > -1) {
            if ((-1 < pidx) && (pidx < plst.count)) {
                if (plst[pidx][2] == "f") {
                    nobj.view_shuf[1] = false
                    plst[pidx][2] = "t"
                } else {
                    nobj.view_shuf[1] = true
                    plst[pidx][2] = "f"
                }
            }
            iidx = 1
        }
        if (nobj.view_shuf[iidx] == false) { nobj.view_shuf[iidx] = true }
        else { nobj.view_shuf[iidx] = false }
    }

    func refz() {
        sldv = [colr(k:"b"), colr(k:"b"), colr(k:"bh"), colr(k:"bh")]
        sldr = [colr(k:"t"), colr(k:"b"), colr(k:"th"), colr(k:"bh")]
        winc = colr(k:"a")
        nobj.view_tabb.clrs.head_back = colr(k:"y")
        nobj.view_tabb.clrs.data_back = colr(k:"w")
        nobj.view_tabb.clrs.body_bord = colr(k:"b")
        nobj.view_tabb.clrs.head_text = colr(k:"l")
        nobj.view_tabb.clrs.head_line_colr = colr(k:"l")
        nobj.view_tabb.clrs.head_divr_colr = colr(k:"l")
        nobj.view_tabb.clrs.head_high_text = colr(k:"lh")
        nobj.view_tabb.clrs.head_high_back = colr(k:"yh")
        nobj.view_tabb.clrs.data_text = colr(k:"l")
        nobj.view_tabb.clrs.data_line_colr = colr(k:"l")
        nobj.view_tabb.clrs.data_high = colr(k:"b")
        wins = 9
        imgl = 0
    }

    func nilc() -> Int {
        for item in clno {
            if (item[0] != 0.0) { return 1 }
        }
        return 0
    }

    func nilz(_ args:Int) {
        var i = 0
        let f = nilc()
        for _ in clno {
            if (f == 0) { clno[i][0] = clno[i][4] }
            else { clno[i][0] = 0.0 }
            i += 1
        }
        wins = 8
        refz()
    }

    func zilw(_ args:Int) {
        wina[0] = 0.0
        wina[1] = 0.0
        wina[2] = 0.19
        wina[3] = 0.0
    }

    func minv(_ args:Int) {
        if (volu[2] == 1.00) {
            mute = true
            volu[2] = 0.00
            nobj.plyr.volume = 0.00
        } else {
            mute = false
            volu[1] = 0.00
            volu[0] = 0.00
            nobj.plyr.volume = 0.00
        }
    }

    func maxv(_ args:Int) {
        if (volu[2] == 1.00) {
            volu[1] = 1.00
            volu[0] = 1.00
        } else if ((volu[1] == 0.00) && (volu[0] == 0.00)) {
            volu[1] = 1.00
            volu[0] = 1.00
        }
        mute = false
        volu[2] = 1.00
        nobj.plyr.volume = Float(volu[1])
    }

    func niln() -> Int {
        print(Date(),"DEBUG","niln")
        return -1
    }

    func noco() -> Color {
        return Color.init(red:0.0, green:0.0, blue:0.0, opacity:0.0)
    }

    func butv(kind:String, size:CGFloat, extr:[CGFloat], iidx:Int, clst:[String], pram:Int, actn:@escaping (Int) -> Void, actc:@escaping () -> Int) -> some View {
        let objc = Image(systemName:kind).resizable().scaledToFit().frame(width:size, height:size).foregroundColor(colr(k:clrs[iidx][2])).onAppear {
            clrs[iidx] = [clst[0], clst[1], clst[2], clst[3], "", ""]
            let zidx = actc()
            if (zidx > -1) {
                clrs[iidx][2] = (clrs[iidx][zidx] + clrs[iidx][5])
                idxf.append([iidx, actc])
            }
        }.onTapGesture {
            actn(pram)
            let fstr = clrs[iidx][2].fstrs(char:"h")
            let jidx = (fstr == clrs[iidx][0]) ? 1 : 0
            clrs[iidx][4] = clrs[iidx][jidx]
            clrs[iidx][2] = (clrs[iidx][jidx] + clrs[iidx][5])
            for item in idxf {
                let yidx = item[0] as? Int
                let meth = item[1] as? () -> Int
                let xidx = yidx!
                let zidx = meth!()
                clrs[xidx][2] = (clrs[xidx][zidx] + clrs[xidx][5])
            }
            if (clrs[iidx][3] == "!") {
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.19) { clrs[iidx][2] = (clrs[iidx][0] + clrs[iidx][5]) }
            }
            focu(0)
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

    func keyp(pres:NSEvent) {
        let mods = pres.modifierFlags.rawValue
        let chrs = pres.keyCode
        print(Date(),"INFO","keyp",mods,chrs,isfo,fobo)
        if ((!fobo) && (!pobo)) {
            if (mods == 0x100) {
                if (chrs == 49) { bply(-1) }
            } else {
                if (chrs == 123) {
                    if (mods == 0xa00100) { prev(-1) }
                    if (mods == 0xb00108) { seek(when:-10) }
                }
                if (chrs == 124) {
                    if (mods == 0xa00100) { more(-1) }
                    if (mods == 0xb00108) { seek(when:10) }
                }
            }
        }
    }

    func imgs(mode:Int) -> Image? {
        let iidx = idxs[0]
        let secs = 1970.time()
        if ((imgd == nil) || ((secs - imgl) >= 5) || (mode != 1)) {
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
            let imgo = Image(nsImage:aimg!)
            if (mode == 1) {
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.0) {
                    imgd = imgo
                    imgl = secs
                }
            }
            return imgo
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
