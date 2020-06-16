import Zee5CoreSDK

class AnalyticsUtil {
    
    func reportTabVisitedAnalyticsIfApplicable(atomFeedUrl: String?) {
        guard let atomFeedUrl = atomFeedUrl else { return }
        guard let base64Url = findQueryStringParameter(url: atomFeedUrl, parameter: "url") else { return }
        guard let dataSourceUrl = decodeBase64(from: base64Url) else { return }
        guard let screenType = findQueryStringParameter(url: dataSourceUrl, parameter: "screen_type") else { return }
        analytics.track(mapScreenTypeToEvent(screenType: screenType), trackedProperties: Set<TrackedProperty>())
        analytics.track(mapScreenTypeToEventV2(screenType: screenType), trackedProperties: Set<TrackedProperty>())
    }

    func findQueryStringParameter(url: String, parameter: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == parameter })?.value
    }

    func decodeBase64(from: String) -> String? {
        guard let data = Data(base64Encoded: from) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func mapScreenTypeToEvent(screenType: String) -> Events {
        switch (screenType) {
        case "home":
            return Events.HOMEPAGE_VISITED
        case "tvshows":
            return Events.TVSHOWSSECTION_VISITED
        case "premium":
            return Events.PREMIUMSECTION_VISITED
        case "movies":
            return Events.MOVIESECTION_VISITED
        case "videos":
            return Events.VIDEOSECTION_VISITED
        case "livetv":
            return Events.LIVETVSECTION_VISITED
        case "news":
            return Events.NEWSSECTION_VISITED
        case "originals":
            return Events.ORIGINALSECTION_VISITED
        default:
            return Events.HOMEPAGE_VISITED
        }
    }
    
    private func mapScreenTypeToEventV2(screenType: String) -> Events {
        switch (screenType) {
        case "home":
            return Events.HOME_CLICK_HOME
        case "tvshows":
            return Events.HOME_CLICK_TVSHOWS
        case "premium":
            return Events.HOME_CLICK_PREMIUM
        case "movies":
            return Events.HOME_CLICK_MOVIES
        case "videos":
            return Events.HOME_CLICK_VIDEOS
        case "livetv":
            return Events.HOME_CLICK_LIVETV
        case "news":
            return Events.HOME_CLICK_NEWS
        case "originals":
            return Events.HOME_CLICK_ORIGINALS
        default:
            return Events.HOME_CLICK_HOME
        }
    }
}
