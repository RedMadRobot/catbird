import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
sealed class CatbirdAction(val type: Type) {
    @Serializable
    enum class Type {
        @SerialName("update") UPDATE,
        @SerialName("remove") REMOVE,
        @SerialName("removeAll") REMOVE_ALL
    }

    @Serializable
    data class Update(
        val pattern: RequestPattern,
        val response: ResponseMock
    ): CatbirdAction(Type.UPDATE)

    @Serializable
    data class Remove(
        val pattern: RequestPattern
    ): CatbirdAction(Type.REMOVE)

    @Serializable
    class RemoveAll: CatbirdAction(Type.REMOVE_ALL)
}
