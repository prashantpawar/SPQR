module Constants = {
  let _gunUrl = ["https://gun-manhattan.herokuapp.com/gun", "http://cashtokens.paper.cash:8765/gun"]
  let gunUrl = []
  let storesLabel = "stores"
}
type status = [#waiting]

let nullT = Js.Nullable.null
open Types
open Constants

module Sea = {
  type sea
  type algorithm = [#"SHA-256" | #PBKDF2]
  type workOpt = {name: algorithm}
  @module("gun/sea.js") external sea: sea = "default"
  @send
  external work: (
    sea,
    string,
    Js.Nullable.t<string>,
    Js.Nullable.t<unit => unit>,
    workOpt,
  ) => Js.Promise.t<storeId> = "work"

  let asyncWork = async (sea, string) => {
    await work(sea, string, nullT, nullT, {name: #"SHA-256"})
  }
}

module Gun = {
  type t
  type gunOpts = {peers: array<string>}
  type storageObj<'t> = 't
  type callback<'a> = 'a => unit
  type callback2<'a, 'b> = ('a, 'b) => unit
  type callback3<'a, 'b, 'c> = ('a, 'b, 'c) => unit
  type subscriber = {off: unit => unit}
  @module("gun") external gun: gunOpts => t = "default"
  // @module("gun/lib/unset.js") external unset_: gun = "default"
  // let _ = unset_
  @send external get: (t, propertyLabel) => t = "get"
  @send external getWithCallback: (t, propertyLabel, callback<'a>) => t = "get"
  @send external put: (t, storageObj<'a>) => promise<unit> = "put"
  @send external putWithCallback: (t, storageObj<'a>, callback<'a>) => Js.Promise.t<unit> = "put"
  @send external once: (t, unit) => promise<'a> = "once"
  @send external onceWithCallback: (t, callback<'a>) => promise<'a> = "once"
  @send external onceWithKey: (t, callback2<'a, 'b>) => subscriber = "once"
  @send external on: (t, callback<'a>) => subscriber = "on"
  @send external onWithKey: (t, callback2<'a, 'b>) => subscriber = "on"
  @send external unset: (t, t) => promise<unit> = "unset"
  @send external set: (t, storageObj<'a>) => promise<unit> = "set"
  @send external map: (t, unit) => t = "map"
}

type queuePosition = {
  customerName: name,
  position: int,
  status: status,
  timestamp: timestamp,
}
type queue = array<queuePosition>
type store = {queue: queue}

let gun = Gun.gun({peers: gunUrl})
let sea = Sea.sea

let registerStore = async (name: name, email: email) => {
  let storeId = await sea->Sea.asyncWork(`${name}:${email}`)

  // Create a new store in GunDB
  let storeRef = gun->Gun.get(storesLabel)->Gun.get(storeId)
  await storeRef->Gun.put({"name": name, "email": email})
  storeId
}

let enterQueue = async (customerName: name, storeId: storeId) => {
  let storeRef = gun->Gun.get("stores")->Gun.get(storeId)
  let store = await storeRef->Gun.once()
  Js.log2("store", store)

  let queue = await storeRef->Gun.get("queue")->Gun.once()
  Js.log2("queue", queue)

  // Create a new queue position object for the user
  let queuePosition = {
    customerName,
    position: 1,
    status: #waiting,
    timestamp: Js.Date.make()->Js.Date.toISOString,
  }

  // Add the queue position object to the store's queue array
  await queue->Gun.set(queuePosition)
  let _ = await queue->Gun.onceWithCallback(x => Js.log2("queueArr", x))

  // Generate a unique queue position ID using the user's name and timestamp
  let queuePositionId = await sea->Sea.asyncWork(`${customerName}:${queuePosition.timestamp}`)

  // Create a new queue position object in GunDB with the generated ID as the reference
  let queuePositionRef =
    gun
    ->Gun.get("queuePositions")
    ->Gun.getWithCallback(queuePositionId, x => Js.log2("queuePositionId", x))

  let queueD = await queuePositionRef->Gun.put(queuePosition)
  Js.log2("queueD", queueD)

  // Return the queue Position ID
  queuePositionId
}

let unsetEverything = async storeId => {
  let storeRef = gun->Gun.get("stores")->Gun.get(storeId)
  await gun->Gun.unset(storeRef)
}

let main = async () => {
  //   let _ = await unsetEverything("McVUPBc00lxyBvX9WRUl0Clb7G/oT/gvlGo0/pcKHmY=")

  let storeId = await registerStore(`My Store 2`, "example@example.com")
  let _ = gun->Gun.get("stores")->Gun.get(storeId)->Gun.on(x => Js.log2("WATCH:", x))
  Js.log2("Store ID: ", storeId)

  let queuePositionId = await enterQueue("John", storeId)
  Js.log2("User entered queue with position ID:", queuePositionId)
}
