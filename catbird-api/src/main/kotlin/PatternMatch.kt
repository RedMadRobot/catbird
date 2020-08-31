import com.google.gson.annotations.SerializedName

data class PatternMatch(
    val kind: Kind = Kind.EQUAL,
    val value: String
) {
    enum class Kind {
        @SerializedName("equal") EQUAL,
        @SerializedName("wildcard") WILDCARD,
        @SerializedName("regexp") REGEXP
    }
}

