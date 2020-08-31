import com.google.gson.Gson
import com.google.gson.GsonBuilder

class JsonEncoder(prettyPrinting: Boolean = false) {
    private val gson = if (prettyPrinting) {
        GsonBuilder().setPrettyPrinting().create()
    } else {
        Gson()
    }

    fun encode(value: Any): String = gson.toJson(value)
}
