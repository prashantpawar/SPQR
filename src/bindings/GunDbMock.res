open Types
let queue = ref([
  {number: 1, time: "10:05AM"},
  {number: 2, time: "10:10AM"},
  {number: 3, time: "10:15AM"},
  {number: 4, time: "10:20AM"},
  {number: 5, time: "10:25AM"},
  {number: 6, time: "10:30AM"},
  {number: 7, time: "10:35AM"},
  {number: 8, time: "10:40AM"},
])
let lastServed = ref(queue.contents->Js.Array2.shift)
let startPosition = {
  number: 1,
  time: Js.Date.make()->Js.Date.toLocaleTimeString,
}

let enterQueue = num => {
  let _ =
    queue.contents->Js.Array2.push({number: num, time: Js.Date.make()->Js.Date.toLocaleTimeString})
  queue
}

let serveNext = () => {
  lastServed := queue.contents->Js.Array2.shift
}
