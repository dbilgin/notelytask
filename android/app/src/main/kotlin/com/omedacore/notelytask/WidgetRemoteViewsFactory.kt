package com.omedacore.notelytask

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONObject

class WidgetRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return WidgetRemoteViewsFactory(this.applicationContext, intent)
    }
}

class WidgetRemoteViewsFactory(applicationContext: Context, intent: Intent) :
    RemoteViewsService.RemoteViewsFactory {
    private val mContext: Context = applicationContext
    private val notesList = mutableListOf<Map<String, Any?>>()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val notes = Utility.readNotesFromPreferences(mContext)
        if (notes.isNullOrEmpty()) return

        val notesJSON = JSONObject(notes)
        val notesData = notesJSON["notes"] as JSONArray

        notesList.clear()
        for (i in 0 until notesData.length()) {
            val note = notesData.getJSONObject(i)
            if (note["isDeleted"] == true) continue

            val id = note["id"].toString()
            val title = note["title"].toString()
            val text = note["text"].toString()

            notesList.add(mapOf("id" to id, "title" to title, "text" to text))
        }
    }

    override fun onDestroy() {
    }

    override fun getCount(): Int {
        return notesList.count()
    }

    override fun getViewAt(position: Int): RemoteViews? {
        if (position + 1 > notesList.count()) {
            return null
        }

        val id = notesList[position]["id"].toString()
        val title = notesList[position]["title"].toString()
        val text = notesList[position]["text"].toString()
        val remoteNote =
            RemoteViews(mContext.packageName, R.layout.widget_note)
        remoteNote.setTextViewText(R.id.title, title)
        remoteNote.setTextViewText(R.id.text, text)

        val fillInIntent = Intent()
        fillInIntent.putExtra("note_id", id)
        remoteNote.setOnClickFillInIntent(R.id.linear_single_note, fillInIntent)

        return remoteNote
    }

    override fun getLoadingView(): RemoteViews? {
        return null;
    }

    override fun getViewTypeCount(): Int {
        return 1;
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }

}