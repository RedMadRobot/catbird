import org.junit.Assert.assertEquals
import org.junit.Test

class PatternMatchTest {
    private val encoder = JsonEncoder(prettyPrint = true)

    @Test
    fun `default kind equal`() {
        val pattern = PatternMatch(value = "accounts")
        assertEquals(PatternMatch.Kind.EQUAL, pattern.kind)
    }

    @Test
    fun `encode equal to json`() {
        val pattern = PatternMatch(
            PatternMatch.Kind.EQUAL,
            "accounts"
        )
        val actual = encoder.encode(pattern)
        var expected = """
        {
            "kind": "equal",
            "value": "accounts"
        }
        """.trimIndent()
        assertEquals(expected, actual)
    }

    @Test
    fun `encode wildcard to json`() {
        val pattern = PatternMatch(
            PatternMatch.Kind.WILDCARD,
            "accounts"
        )
        val actual = encoder.encode(pattern)
        var expected = """
        {
            "kind": "wildcard",
            "value": "accounts"
        }
        """.trimIndent()
        assertEquals(expected, actual)
    }

    @Test
    fun `encode regexp to json`() {
        val pattern = PatternMatch(
            PatternMatch.Kind.REGEXP,
            "accounts"
        )
        val actual = encoder.encode(pattern)
        var expected = """
        {
            "kind": "regexp",
            "value": "accounts"
        }
        """.trimIndent()
        assertEquals(expected, actual)
    }
}