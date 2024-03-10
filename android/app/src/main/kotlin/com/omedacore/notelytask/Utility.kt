package com.omedacore.notelytask

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews

class Utility {
    companion object {
        fun writeNotesToPreferences(
            context: Context,
            notes: String,
        ) {
            val sharedPref = context.getSharedPreferences("notes", Context.MODE_PRIVATE) ?: return
            with(sharedPref.edit()) {
                putString("notes", notes)
                apply()
            }
        }

        fun readNotesFromPreferences(context: Context): String? {
            val sharedPref =
                context.getSharedPreferences("notes", Context.MODE_PRIVATE) ?: return null
            return sharedPref.getString("notes", null)
        }

        fun setTemplateClickListener(context: Context, views: RemoteViews) {
            val intent = Intent(context, MainActivity::class.java)
            val flags =
                if (Build.VERSION.SDK_INT > 30)
                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                else PendingIntent.FLAG_UPDATE_CURRENT

            val flag =
                if (Build.VERSION.SDK_INT > 30) PendingIntent.FLAG_MUTABLE
                else 0

            val pendingIntent = PendingIntent.getActivity(context, 0, intent, flag)
            views.setPendingIntentTemplate(R.id.notes_layout, pendingIntent)
        }
    }
}