import CatbirdAPI

protocol BagsResponseStore {
 
    var bags: [RequestBag] { get }
}
