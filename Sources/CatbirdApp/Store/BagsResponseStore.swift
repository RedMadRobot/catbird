import CatbirdAPI

protocol BagsResponseStore {
 
    var bags: [RequestPattern : ResponseData] { get }
}
