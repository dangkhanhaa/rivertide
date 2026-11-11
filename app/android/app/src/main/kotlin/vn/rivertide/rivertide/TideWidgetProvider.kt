package vn.rivertide.rivertide

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import java.util.Locale
import kotlin.math.abs

/**
 * Home-screen widget for the first saved place. The app stores the next 48
 * hourly levels (`levels`: [[epochSeconds, cm], ...]) so the widget can show
 * the level for the current time by itself between app launches; the system
 * refreshes it every 30 minutes (updatePeriodMillis).
 */
class TideWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val nowSec = System.currentTimeMillis() / 1000
        val place = widgetData.getString("place", null)
        val level = levelAt(widgetData.getString("levels", null), nowSec)
        val ahead = levelAt(widgetData.getString("levels", null), nowSec + 3600)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.tide_widget)
            views.setTextViewText(
                R.id.widget_place,
                place ?: context.getString(R.string.widget_no_place),
            )
            if (level == null) {
                views.setTextViewText(R.id.widget_level, "—")
                views.setTextViewText(R.id.widget_trend, context.getString(R.string.widget_open_app))
            } else {
                views.setTextViewText(R.id.widget_level, metres(level))
                val rate = if (ahead == null) 0.0 else ahead - level
                views.setTextViewText(
                    R.id.widget_trend,
                    context.getString(
                        when {
                            abs(rate) < 3 -> R.string.widget_slack
                            rate > 0 -> R.string.widget_rising
                            else -> R.string.widget_falling
                        },
                    ),
                )
            }
            views.setTextViewText(R.id.widget_next, nextTurn(context, widgetData.getString("extremes", null), nowSec))
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    /** Linear interpolation between the stored hourly points; null outside them. */
    private fun levelAt(json: String?, atSec: Long): Double? {
        if (json == null) return null
        return try {
            val arr = JSONArray(json)
            for (i in 0 until arr.length() - 1) {
                val a = arr.getJSONArray(i)
                val b = arr.getJSONArray(i + 1)
                val ta = a.getLong(0)
                val tb = b.getLong(0)
                if (atSec in ta..tb && tb > ta) {
                    val f = (atSec - ta).toDouble() / (tb - ta)
                    return a.getDouble(1) + f * (b.getDouble(1) - a.getDouble(1))
                }
            }
            null
        } catch (e: org.json.JSONException) {
            null
        }
    }

    /** First high/low still ahead: "Đỉnh 15:30 · 4,20 m" (Vietnam time). */
    private fun nextTurn(context: Context, json: String?, nowSec: Long): String {
        if (json == null) return ""
        return try {
            val arr = JSONArray(json)
            val fmt = java.text.SimpleDateFormat("HH:mm", Locale.US).apply {
                timeZone = java.util.TimeZone.getTimeZone("Asia/Ho_Chi_Minh")
            }
            for (i in 0 until arr.length()) {
                val e = arr.getJSONArray(i)
                val t = e.getLong(0)
                if (t <= nowSec) continue
                val name = context.getString(
                    if (e.getString(2) == "H") R.string.widget_high else R.string.widget_low,
                )
                return "$name ${fmt.format(java.util.Date(t * 1000))} · ${metres(e.getDouble(1))}"
            }
            ""
        } catch (e: org.json.JSONException) {
            ""
        }
    }

    /** "1,42 m" — Vietnamese decimal comma, like the app. */
    private fun metres(cm: Double): String =
        String.format(Locale.US, "%.2f m", cm / 100).replace('.', ',')
}
