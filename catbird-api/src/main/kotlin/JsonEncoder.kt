import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.*

class JsonEncoder(prettyPrint: Boolean = false) {
    val json = Json {
        this.prettyPrint = prettyPrint
        this.classDiscriminator = "_type"
    }

    inline fun <reified T> encode(value: T): String =
        json.encodeToString(value)
}
