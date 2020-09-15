import kotlinx.serialization.Serializable
import java.nio.file.Files
import java.nio.file.Paths
import java.util.Base64

@Serializable
data class ResponseMock(
    var status: Int = 200,
    var headers: MutableMap<String, String> = mutableMapOf(),
    var body: String? = null,
    var limit: Int? = null,
    var delay: Int? = null,
) {
    fun setHeader(name: String, value: String) {
        headers[name] = value
    }

    fun setCookie(value: String) {
        setHeader("Set-Cookie", value)
    }

    fun setFile(path: String) {
        val fileBytes = Files.readAllBytes(Paths.get(path))
        val encodedBytes = Base64.getEncoder().encode(fileBytes)
        body = String(encodedBytes)
    }

    fun setString(string: String) {
        body = Base64.getEncoder().encodeToString(string.toByteArray())
    }
}