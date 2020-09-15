import org.junit.Assert.assertEquals
import org.junit.Test

class CatbirdActionTest {
    private val encoder = JsonEncoder(prettyPrint = true)

    @Test
    fun `encode update action`() {
        val pattern = RequestPattern()
        val response = ResponseMock()
        val action = CatbirdAction.Update(pattern, response)
        val actual = encoder.encode(action)
        var expected = """
        {
            "type": "update",
            "pattern": {
                "method": "GET",
                "url": {
                    "kind": "equal",
                    "value": ""
                },
                "headers": {
                }
            },
            "response": {
                "status": 200,
                "headers": {
                },
                "body": null,
                "limit": null,
                "delay": null
            }
        }
        """.trimIndent()
        assertEquals(expected, actual)
    }

    @Test
    fun `encode remove action`() {
        val pattern = RequestPattern()
        val action = CatbirdAction.Remove(pattern)
        val actual = encoder.encode(action)
        var expected = """
        {
            "type": "remove",
            "pattern": {
                "method": "GET",
                "url": {
                    "kind": "equal",
                    "value": ""
                },
                "headers": {
                }
            }
        }
        """.trimIndent()
        assertEquals(expected, actual)
    }

    @Test
    fun `encode remove all action`() {
        val action = CatbirdAction.RemoveAll()
        val actual = encoder.encode(action)
        var expected = """
        {
            "type": "removeAll"
        }
        """.trimIndent()
        assertEquals(expected, actual)
    }
}
