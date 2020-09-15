import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class PatternMatch(
    val kind: Kind = Kind.EQUAL,
    val value: String
) {
    @Serializable
    enum class Kind {
        @SerialName("equal") EQUAL,
        @SerialName("wildcard") WILDCARD,
        @SerialName("regexp") REGEXP
    }

    companion object {
        @JvmStatic
        fun equal(value: String) =
            PatternMatch(Kind.EQUAL, value)

        @JvmStatic
        fun wildcard(value: String) =
            PatternMatch(Kind.WILDCARD, value)

        @JvmStatic
        fun regexp(value: String) =
            PatternMatch(Kind.REGEXP, value)
    }
}

