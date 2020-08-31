import com.google.gson.annotations.SerializedName

sealed class CatbirdAction(val type: Type) {
    enum class Type {
        @SerializedName("update") UPDATE,
        @SerializedName("remove") REMOVE,
        @SerializedName("removeAll") REMOVE_ALL
    }

    class Update(val pattern: RequestPattern, val response: ResponseMock): CatbirdAction(Type.UPDATE)
    class Remove(val pattern: RequestPattern): CatbirdAction(Type.REMOVE)
    object RemoveAll: CatbirdAction(Type.REMOVE_ALL)
}
