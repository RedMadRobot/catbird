import org.junit.Assert.assertEquals
import org.junit.Test

class RequestPatternTest {
    private val encoder = JsonEncoder(prettyPrint = true)

    @Test
    fun `default values`() {
        val actual = RequestPattern()
        val expected = RequestPattern(
            method = "GET",
            url = PatternMatch.equal(""),
            headers = mutableMapOf()
        )
        assertEquals(expected, actual)
    }

    @Test
    fun `set header`() {
        val request = RequestPattern()
        request.setHeader("a", "b")
        request.setHeader("1", "2")
        val actual = request.headers
        val expected = mapOf(
            "a" to PatternMatch.equal("b"),
            "1" to PatternMatch.equal("2")
        )
        assertEquals(expected, actual)
    }

    @Test
    fun `set cookie`() {
        val request = RequestPattern()
        request.setCookie("x")
        val actual = request.headers
        val expected = mapOf("Cookie" to PatternMatch.equal("x"))
        assertEquals(expected, actual)
    }

    @Test
    fun `encode with default values`() {
        val request = RequestPattern()
        val actual = encoder.encode(request)
        val expected = """
        {
            "method": "GET",
            "url": {
                "kind": "equal",
                "value": ""
            },
            "headers": {
            }
        }
        """.trimIndent()
        assertEquals(expected, actual)
    }

    @Test
    fun `encode with all values`() {
        val request = RequestPattern(
            method = "POST",
            url = PatternMatch(value = "/accounts"),
            headers = mutableMapOf("z" to PatternMatch.wildcard("*"))
        )
        val actual = encoder.encode(request)
        val expected = """
        {
            "method": "POST",
            "url": {
                "kind": "equal",
                "value": "/accounts"
            },
            "headers": {
                "z": {
                    "kind": "wildcard",
                    "value": "*"
                }
            }
        }
        """.trimIndent()
        assertEquals(expected, actual)
    }
}