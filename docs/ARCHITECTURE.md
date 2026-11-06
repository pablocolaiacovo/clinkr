# Clinkr architecture

How the iPhone app and the Apple Watch app fit together. Solid lines are what exists today. Dashed boxes and lines are the usual next pieces, which aren't built yet.

## 1. From project to devices

One Xcode project builds two apps. The Watch app is packed inside the iPhone app, and the Watch installs it automatically when the iPhone app is installed.

```mermaid
flowchart LR
    subgraph xcode["Clinkr.xcodeproj"]
        t1["Target: Clinkr<br/>(iOS 26+)"]
        t2["Target: Clinkr Watch App<br/>(watchOS 26+)"]
    end

    subgraph bundle["Clinkr.app"]
        phoneBin["iPhone app code"]
        subgraph watchFolder["Watch/"]
            watchBin["Clinkr Watch App.app"]
        end
    end

    t1 -- builds --> phoneBin
    t2 -- builds --> watchBin

    bundle -- "installed via Xcode,<br/>TestFlight or App Store" --> iphone["iPhone"]
    iphone -- "auto-installs<br/>Watch app" --> watch["Apple Watch"]
```

## 2. Inside each app

Both apps are SwiftUI apps with the same shape. Each one starts at an `@main` App struct, which shows a `ContentView`. Both compile `Shared/`: the data model (`DrinkType`, `DrinkEntry`, `Night`) and the design system (colors, text styles, spacing, radii and drink glyphs). The Watch's screens are vertical pages: Tonight, with the `TallyRing`, then Add, then Night, which lists tonight's entries (a swipe removes one) and ends the night. The Watch keeps tonight in `NightStore`, which the Add screen's drink buttons and a tap on the ring write to. The store remembers the last entry added, and `ContentView` shows an `UndoToast` for it under the screen for 5 seconds; Undo removes that entry. After 4 drinks in a row with no water, `ContentView` also slides up a `WaterNudgeView` once that drink's toast has had its 5 seconds, at most once an hour and never within 30 minutes of a "Later". A night ends with End night, or when the next drink comes after a 12-hour gap (End night that late also counts from the last entry), and then moves to `pendingNights`, a queue waiting for the iPhone sync. For 5 seconds after End night, Undo takes the night back out of the queue with `reopenNight(id:)`, as long as it's still the last night there and no new one has started. Once Undo is over, `NightSender` sends the night to the iPhone. On the iPhone, `NightReceiver` starts at launch and saves each night it receives as a `SavedNight` in SwiftData, Apple's on-device database, skipping any id it already has. It then sends a receipt back, and only that removes the night from the Watch's queue. Until then, the Watch sends the night again whenever the app comes and goes, and a background refresh about every 15 minutes does the same. If the database won't open, the iPhone shows a message instead of the list and receives nothing, so the Watch keeps its nights. `ContentView` is a plain list of those nights until the History screen (#12) replaces it.

```mermaid
flowchart TB
    subgraph phone["iPhone app (Clinkr/)"]
        pApp["ClinkrApp<br/>@main entry point"] --> pView["ContentView<br/>SwiftUI screen"]
        pModel["SavedNight<br/>SwiftData database"]
        pSync["NightReceiver<br/>(WCSession)"]
        pView -- "reads" --> pModel
        pSync -- "insertIfNew(night)" --> pModel
    end

    subgraph watch["Watch app (Clinkr Watch App/)"]
        wApp["ClinkrWatchApp<br/>@main entry point"] --> wView["ContentView"]
        wView --> wTonight["TonightView<br/>TallyRing + count"]
        wView --> wAdd["AddView<br/>DrinkButton grid"]
        wView --> wToast["UndoToast<br/>5 s after every add"]
        wView --> wNudge["WaterNudgeView<br/>after 4 drinks, no water"]
        wView --> wNight["NightView<br/>entries + End night"]
        wModel["NightStore<br/>tonight + pendingNights,<br/>saved to nights.json"]
        wSync["NightSender<br/>(WCSession)"]
        wApp --> wModel
        wAdd -- "add(type)" --> wModel
        wTonight -- "add(last drink)" --> wModel
        wModel -- "lastAdded" --> wToast
        wToast -- "removeEntry(id)" --> wModel
        wNudge -- "add(.water)" --> wModel
        wNight -- "removeEntry(id), endNight(), reopenNight(id)" --> wModel
        wModel -- "nightsReadyToSend" --> wSync
        wSync -- "removePendingNight(id)" --> wModel
    end

    shared["Shared/<br/>DrinkType, DrinkEntry, Night<br/>design tokens, glyphs"]
    shared --> pModel
    shared --> wModel
    shared --> wAdd

    wSync -- "night, by transferUserInfo<br/>(Bluetooth / Wi-Fi)" --> pSync
    pSync -- "saved receipt" --> wSync
```

## 3. How a night travels from the Watch to the iPhone

Apple's WatchConnectivity framework queues the night and delivers it when it can, even if the iPhone app isn't running. The system wakes the iPhone app in the background to receive it. The Watch keeps the night until the iPhone's receipt arrives and sends it again if it can, so a night can arrive more than once. The iPhone matches by id and sends a receipt each time.

```mermaid
sequenceDiagram
    actor User
    participant W as Watch app
    participant WC as WatchConnectivity (system)
    participant P as iPhone app

    User->>W: End night
    W->>W: Queue the night in nights.json
    Note over W: Held back for 5 seconds, while Undo shows
    W->>WC: transferUserInfo(night)
    WC->>P: didReceiveUserInfo, when the system decides
    P->>P: Save it unless the id is already there
    P->>WC: transferUserInfo(saved receipt)
    WC->>W: didReceiveUserInfo
    W->>W: Remove the night from the queue
```
