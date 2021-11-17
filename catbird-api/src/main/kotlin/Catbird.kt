import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

class Catbird(
    var url: URL = URL(LOCAL_HOST),
    var encoder: JsonEncoder = JsonEncoder()
) {
    companion object {
        const val LOCAL_HOST = "http://127.0.0.1:8080"
        const val ACTION_PATH = "/catbird/api/mocks"
    }

    fun update(mock: CatbirdMock) {
        perform(CatbirdAction.Update(mock.pattern, mock.response))
    }

    fun remove(mock: CatbirdMock) {
        perform(CatbirdAction.Remove(mock.pattern))
    }

    fun removeAll() {
        perform(CatbirdAction.RemoveAll())
    }

    fun perform(action: CatbirdAction) {
        val body = encoder.encode(action)
        val url = this.url.toURI().resolve(ACTION_PATH).toURL();
        post(url, body)
    }

    private fun post(url: URL, body: String) {
        with(url.openConnection() as HttpURLConnection) {
            requestMethod = "POST"
            doOutput = true
            setRequestProperty("Content-Type", "application/json")

            OutputStreamWriter(outputStream).use {
                it.write(body)
                it.flush()
            }

            inputStream.bufferedReader().use {
                print(it.readText())
            }
        }
    }
}
