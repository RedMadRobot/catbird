data class RequestPattern(
    var method: String = "GET",
    var url: PatternMatch = PatternMatch(value = ""),
    var headers: MutableMap<String, PatternMatch> = mutableMapOf()
) {
    fun setPath(string: String) {
        url = PatternMatch(value = string)
    }

    fun setPathWildcard(string: String) {
        url = PatternMatch(PatternMatch.Kind.WILDCARD, string)
    }

    fun setHeader(name: String, value: String) {
        headers[name] = PatternMatch(value = value)
    }

    fun setCookie(value: String) {
        setHeader("Cookie", value)
    }
}