package shared.project.analytics;
import shared.project.analytics.events.common.DtdAnalyticsBaseEvent;
import shared.project.analytics.events.common.DtdAnalyticsEvent;

class DtdAnalytics {
    private var events:Array<DtdAnalyticsBaseEvent>;
    //private var events:Map<String, DtdAnalyticEvent>;

    public function new() {
        events = new Array();
    }


    public function trackEvent(event:DtdAnalyticsBaseEvent) {
        events.push(event);
    }

    public function getEvents():Array<DtdAnalyticsBaseEvent> {
        return events;
    }


}


