# 🚀 Simple Make.com Setup for Book Enrichment

**Goal**: Process 739 books from queue using local enrichment agent

---

## ⚡ **What You Need**

1. **Local Agent**: ✅ Running on port 3005
2. **ngrok Tunnel**: Expose agent to internet
3. **Make.com Scenario**: Call agent every 5 minutes

---

## 🔧 **Step 1: Start ngrok**

```bash
ngrok http 3005
```

Copy the https URL (example: `https://abc123.ngrok.io`)

---

## 🎯 **Step 2: Create Make.com Scenario**

### **Module 1: HTTP Request**
- **URL**: `https://YOUR-NGROK-URL.ngrok.io/process-queue`
- **Method**: POST
- **Headers**: `Content-Type: application/json`
- **Body**: `{}` (empty JSON)

### **Module 2: Router (Optional)**
- **Condition**: `{{1.success}} = true`
- Routes to logging/monitoring if needed

**That's it!** No complex modules needed.

---

## ⚙️ **Step 3: Schedule**

- **Type**: Interval
- **Every**: 5 minutes
- **Start**: Immediately

---

## 📊 **What Happens**

```
Make.com → ngrok → Local Agent → Process 1 Book → Update Database
```

**Every 5 minutes**:
1. Make.com calls your local agent
2. Agent picks next book from queue (739 pending)
3. Agent enriches book with description, keywords, year
4. Agent updates database
5. Agent marks book as completed

**Timeline**: 739 books ÷ 12 per hour = ~62 hours for full enrichment

---

## 🧪 **Test First**

Before setting up Make.com, test locally:

```bash
# Test single book processing
curl -X POST http://localhost:3005/process-queue

# Should return:
{
  "success": true,
  "processed_book": {
    "id": "uuid",
    "title": "Book Title",
    "enriched_fields": {...}
  }
}
```

---

## 🎯 **Make.com Scenario JSON**

```json
{
  "name": "Book Enrichment Agent",
  "scheduling": {
    "type": "interval",
    "interval": 5,
    "intervalType": "minutes"
  },
  "flow": [
    {
      "id": 1,
      "module": "http:ActionSendData",
      "version": 3,
      "parameters": {
        "url": "https://YOUR-NGROK-URL.ngrok.io/process-queue",
        "method": "post",
        "headers": [
          {
            "name": "Content-Type",
            "value": "application/json"
          }
        ],
        "qs": [],
        "bodyType": "raw",
        "parseResponse": true,
        "bodyRaw": "{}"
      }
    }
  ]
}
```

**Replace `YOUR-NGROK-URL` with your actual ngrok URL.**

---

## ✅ **Success Criteria**

- ✅ Agent responds to `/process-queue`
- ✅ Make.com calls agent every 5 minutes  
- ✅ Books get enriched with descriptions and keywords
- ✅ Queue count decreases over time

**Monitor progress**: Check queue count in database to see books being processed.

---

**🎉 That's it! Simple, focused, working.**