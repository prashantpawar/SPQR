@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()

  switch url.path {
  | list{"store", storeId} => <Store storeId={storeId->Js.Global.decodeURIComponent} />
  | list{} => <Home />
  | _ => <PageNotFound />
  }
}
