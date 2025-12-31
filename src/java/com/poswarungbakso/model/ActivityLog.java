package com.poswarungbakso.model;

public class ActivityLog {
    private int id;
    private String activity;
    private long timestamp;

    public ActivityLog() {}
    public ActivityLog(String activity, long timestamp) {
        this.activity = activity;
        this.timestamp = timestamp;
    }

    // Getter & Setter
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getActivity() { return activity; }
    public void setActivity(String activity) { this.activity = activity; }
    public long getTimestamp() { return timestamp; }
    public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
}