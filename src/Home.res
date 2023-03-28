open Types
type action =
  | RegisterStore
  | RegisterStoreSuccess
  | RegisterStoreFailure
  | StoreNameChanged(name)
  | StoreEmailChanged(email)

type state = {
  storeName: name,
  storeEmail: email,
  message: string,
}

let reducer = (state, action) => {
  switch action {
  | RegisterStore => {
      ...state,
      message: "Registering your store",
    }
  | RegisterStoreSuccess => {
      ...state,
      message: "Store Registered",
    }
  | RegisterStoreFailure => {
      ...state,
      message: "Error while registering your store",
    }
  | StoreNameChanged(name) => {
      ...state,
      storeName: name,
    }
  | StoreEmailChanged(email) => {
      ...state,
      storeEmail: email,
    }
  }
}

@react.component
let make = _ => {
  let (state, dispatch) = React.useReducer(reducer, {storeName: "", storeEmail: "", message: ""})

  let handleRegisterStore = _ => {
    open Js.Promise2
    let _ =
      GunDbMock.registerStore(~name=state.storeName, ~email=state.storeEmail)
      ->then(storeId => {
        dispatch(RegisterStoreSuccess)
        RescriptReactRouter.push(`/store/${storeId->Js.Global.encodeURIComponent}`)->resolve
      })
      ->catch(_ => {
        dispatch(RegisterStoreFailure)->resolve
      })
  }
  <>
    <div
      className="flex flex-col max-w-md px-4 py-8 bg-white rounded-lg shadow dark:bg-gray-800 sm:px-6 md:px-8 lg:px-10">
      <div
        className="self-center mb-2 text-xl font-light text-gray-800 sm:text-2xl dark:text-white">
        {"Register your store"->React.string}
      </div>
      <span
        className="justify-center text-sm text-center text-gray-500 flex-items-center dark:text-gray-400">
        {"Already have a store ? "->React.string}
        <a href="#" target="_blank" className="text-sm text-blue-500 underline hover:text-blue-700">
          {"Sign in"->React.string}
        </a>
      </span>
      <div className="p-6 mt-8">
        <form action="#">
          <div className="flex flex-col mb-2">
            <div className=" relative ">
              <input
                type_="text"
                id="create-account-pseudo"
                className=" rounded-lg border-transparent flex-1 appearance-none border border-gray-300 w-full py-2 px-4 bg-white text-gray-700 placeholder-gray-400 shadow-sm text-base focus:outline-none focus:ring-2 focus:ring-purple-600 focus:border-transparent"
                name="storename"
                onChange={e => dispatch(StoreNameChanged((e->ReactEvent.Form.target)["value"]))}
                placeholder="Acme Store"
                value={state.storeName}
              />
            </div>
          </div>
          <div className="flex flex-col mb-2">
            <div className=" relative ">
              <input
                type_="text"
                id="create-account-email"
                className=" rounded-lg border-transparent flex-1 appearance-none border border-gray-300 w-full py-2 px-4 bg-white text-gray-700 placeholder-gray-400 shadow-sm text-base focus:outline-none focus:ring-2 focus:ring-purple-600 focus:border-transparent"
                onChange={e => dispatch(StoreEmailChanged((e->ReactEvent.Form.target)["value"]))}
                placeholder="Email"
                value={state.storeEmail}
              />
            </div>
          </div>
          <div className="flex w-full my-4">
            <button
              type_="button"
              onClick={handleRegisterStore}
              className="py-2 px-4  bg-purple-600 hover:bg-purple-700 focus:ring-purple-500 focus:ring-offset-purple-200 text-white w-full transition ease-in duration-200 text-center text-base font-semibold shadow-md focus:outline-none focus:ring-2 focus:ring-offset-2  rounded-lg ">
              {"Register"->React.string}
            </button>
          </div>
        </form>
      </div>
    </div>
  </>
}
