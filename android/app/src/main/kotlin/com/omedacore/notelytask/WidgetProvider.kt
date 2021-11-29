package com.omedacore.notelytask

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                try {
                    val notes = widgetData.getString("_notes", null)
                    if (notes.isNullOrEmpty()) return
                    Utility.writeNotesToPreferences(context, notes)

                    val intent = Intent(context, WidgetRemoteViewsService::class.java)
                    setRemoteAdapter(R.id.notes_layout, intent);
                } catch (e: Exception) {

                }
            }

            Utility.setTemplateClickListener(context, views)

            appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.notes_layout)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
