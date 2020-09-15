import org.junit.Assert.assertEquals
import org.junit.Test

class ResponseMockTest {
    private val encoder = JsonEncoder(prettyPrint = true)

    @Test
    fun `default values`() {
        val actual = ResponseMock()
        val expected = ResponseMock(
            status = 200,
            headers = mutableMapOf(),
            body = null,
            limit = null,
            delay = null
        )
        assertEquals(expected, actual)
    }

    @Test
    fun `set header`() {
        val response = ResponseMock()
        response.setHeader("a", "b")
        response.setHeader("1", "2")
        assertEquals(mapOf("a" to "b", "1" to "2"), response.headers)
    }

    @Test
    fun `set cookie`() {
        val response = ResponseMock()
        response.setCookie("x")
        assertEquals(mapOf("Set-Cookie" to "x"), response.headers)
    }

    @Test
    fun `encode with default values`() {
        val response = ResponseMock()
        val actual = encoder.encode(response)
        val expected = """
        {
            "status": 200,
            "headers": {
            },
            "body": null,
            "limit": null,
            "delay": null
        }
        """.trimIndent()
        assertEquals(expected, actual)
    }

    @Test
    fun `encode with all values`() {
        val response = ResponseMock(
            status = 500,
            headers = mutableMapOf("x" to "y"),
            body = "hello",
            limit = 1,
            delay = 4
        )
        val actual = encoder.encode(response)
        val expected = """
        {
            "status": 500,
            "headers": {
                "x": "y"
            },
            "body": "hello",
            "limit": 1,
            "delay": 4
        }
        """.trimIndent()
        assertEquals(expected, actual)
    }
}