# JanSetu — जनसेतु

### A citizen bridge from infrastructure complaints to actionable priorities.

JanSetu is a **voice-first, multilingual infrastructure reporting platform** that turns scattered citizen complaints into geographically clustered, scored, and explainable priority hotspots for policymakers.

Instead of giving decision-makers another raw complaint inbox, JanSetu answers:

> **Where is infrastructure demand concentrated, how severe is it, and why should it be prioritized?**

---

## 🚀 What JanSetu does

A citizen can report a problem through **voice, text, or chat**:

> “The road near our school becomes unusable whenever it rains.”

JanSetu then:

1. **Transcribes** voice input using Whisper
2. **Detects the language** and normalizes the text for processing
3. **Classifies** the infrastructure issue
4. **Extracts and geocodes** the reported location
5. **Stores** the structured request in MongoDB
6. **Clusters** geographically related requests using DBSCAN
7. **Scores** each hotspot using demand, severity, deprivation, and scheme alignment
8. **Surfaces** a ranked, explainable list on the policymaker dashboard

### The output

**Raw complaints**

→ **Structured requests**

→ **Geographic hotspots**

→ **Priority scores**

→ **Explainable project signals**

---

## 🎯 Why this matters

Infrastructure problems are often reported through fragmented channels and in multiple languages.

A large complaint volume does not automatically tell a policymaker:

* where demand is concentrated,
* whether the issue is locally severe,
* how deprivation affects the priority,
* whether an existing government scheme is relevant, or
* why one cluster should receive attention before another.

JanSetu adds this **aggregation + prioritization layer** between citizen reporting and policy action.

---

## 🏗️ Architecture

```text
                         JANSETU
                            │
             ┌──────────────┴──────────────┐
             │                             │
       /citizen route                /dashboard route
             │                             ▲
       React + Vite                        │
          Vercel                           │
             │                             │
             └──────────┬──────────────────┘
                        │
                  POST /api/requests
                        │
                        ▼
             ┌──────────────────────┐
             │   FastAPI + LangGraph│
             │       Render         │
             ├──────────────────────┤
             │ Router               │
             │ Whisper STT          │
             │ Normalize / Translate│
             │ Classify             │
             │ Geocode              │
             │ Persist              │
             └──────────┬───────────┘
                        │
                        ▼
                    MongoDB
                        │
                        ▼
             ┌──────────────────────┐
             │ Aggregation + Scoring│
             │       Render         │
             ├──────────────────────┤
             │ DBSCAN clustering    │
             │ Priority scoring     │
             │ Explainability       │
             └──────────┬───────────┘
                        │
                        ▼
                  hotspots
                        │
                        ▼
                Policymaker UI
          Leaflet + Ranked List + Charts
```

### Deployment model

| Component           | Technology                | Deployment   |
| ------------------- | ------------------------- | ------------ |
| Citizen + Dashboard | React / Vite              | Vercel       |
| API + AI pipeline   | FastAPI + LangGraph       | Render       |
| Database            | MongoDB                   | MongoDB      |
| Geocoding           | Nominatim / OpenStreetMap | External API |
| STT                 | Whisper                   | Backend      |
| Clustering          | scikit-learn DBSCAN       | Backend job  |

The frontend is intentionally **one React application with two routes**:

```text
/citizen
/dashboard
```

This gives the prototype **one Vercel URL** that can be submitted as the working prototype link.

---

## 🧠 Priority scoring

Each geographic/category cluster receives a transparent priority score:

```text
Priority Score =
    w1 × volume
  + w2 × category_severity
  + w3 × infrastructure_deprivation
  + w4 × scheme_alignment
```

### Current signals

**Volume**
How many citizen requests belong to the cluster.

**Category severity**
A category-specific urgency weight.

**Infrastructure deprivation**
A district-level deprivation signal.

**Scheme alignment**
A bonus when an existing government scheme is relevant to the reported need.

Every hotspot also receives a human-readable explanation, for example:

> **High demand + severe water shortage + high district deprivation + aligned scheme**

The goal is not to hide the decision behind a black-box score. The score is accompanied by the evidence that produced it.

---

## 📊 Data model

### `requests`

```javascript
{
  _id,
  raw_text,
  translated_text,
  language,
  category,
  lat,
  lng,
  district,
  source: "voice" | "text" | "chat",
  created_at
}
```

### `hotspots`

```javascript
{
  _id,
  cluster_id,
  category,
  district,
  request_count,
  priority_score,
  explainability_text,
  center_lat,
  center_lng
}
```

---

## 🖥️ Dashboard

The policymaker dashboard provides:

* 🗺️ **Leaflet heatmap** of demand hotspots
* 📋 **Ranked priority list**
* 🔎 **Category and district filters**
* 📊 **Category breakdown**
* 📈 **Request volume over time**
* 💡 **Explainability text for every hotspot**

The dashboard is designed for **triage and prioritization**, rather than simply displaying every complaint individually.

---

## 🗣️ Citizen experience

The `/citizen` route supports three input modes:

### Voice

Record a complaint directly in the browser.

```text
🎙️ Speak
   ↓
Whisper
   ↓
Language detected
   ↓
Structured request
```

### Text

Submit a written infrastructure complaint through the same API.

### Chat

A mock WhatsApp-style interface demonstrates how future channels can use the same backend.

The backend contract is intentionally channel-agnostic:

```text
WhatsApp
IVR
SMS
Web
Mobile app
Assisted service

       ↓

POST /api/requests

       ↓

JanSetu pipeline
```

This means adding a new intake channel does not require redesigning the processing pipeline.

---

## 🧪 Demo data

The prototype uses approximately **40–60 synthetic but plausible requests** distributed across a small number of categories and districts.

This is intentional.

The prototype does **not** depend on collecting real citizen data during the demo.

Seeded data makes clustering and ranking:

* deterministic,
* reproducible,
* safe for demonstration, and
* available immediately after deployment.

---

# ⚡ Quick start

## 1. Clone the repository

```bash
git clone https://github.com/sambhavi0/Jansetu.git
cd Jansetu
```

---

# Backend

## 2. Create the Python environment

```bash
cd backend

python3 -m venv venv
source venv/bin/activate

pip install -r requirements.txt
```

Create your environment file:

```bash
cp .env.example .env
```

At minimum, configure:

```env
MONGODB_URI=your_mongodb_connection_string
```

Optional:

```env
ELEVENLABS_API_KEY=your_key
```

---

## 3. Install FFmpeg

Whisper requires FFmpeg for audio processing.

### macOS

```bash
brew install ffmpeg
```

### Ubuntu / Debian

```bash
sudo apt install ffmpeg
```

If Whisper is unavailable, JanSetu has a **stub transcription fallback** so the rest of the pipeline remains demoable.

---

## 4. Start the API

From `backend/`:

```bash
uvicorn main:app --reload --port 8000
```

API:

```text
http://localhost:8000
```

Interactive API documentation:

```text
http://localhost:8000/docs
```

---

## 5. Seed demo data

In another terminal:

```bash
cd backend
source venv/bin/activate

python -m seed.seed_requests
```

This populates MongoDB with synthetic infrastructure reports.

---

## 6. Generate hotspots

```bash
python -m scoring.run_scoring
```

Then verify:

```bash
curl http://localhost:8000/api/hotspots
```

You should now see the generated hotspot records.

---

## 7. Run the full demo loop

Submit a new request through:

```text
POST /api/requests
```

Then recompute:

```text
POST /api/hotspots/recompute
```

Finally retrieve:

```text
GET /api/hotspots
```

This allows the demo to show how a new citizen report can affect the aggregated priority view.

---

# Frontend

From the repository root:

```bash
cd frontend

npm install
npm run dev
```

Configure the backend URL according to the frontend's environment configuration.

The application contains:

```text
/citizen
/dashboard
```

---

# 📁 Repository structure

```text
jansetu/
│
├── frontend/
│   ├── src/
│   │   ├── pages/
│   │   │   ├── CitizenIntake.jsx
│   │   │   └── Dashboard.jsx
│   │   │
│   │   └── components/
│   │       ├── VoiceRecorder
│   │       ├── Heatmap
│   │       ├── RankedList
│   │       └── Charts
│   │
│   └── ...
│
├── backend/
│   ├── main.py
│   │
│   ├── pipeline/
│   │   ├── stt.py
│   │   ├── graph.py
│   │   ├── classify.py
│   │   ├── translate.py
│   │   └── geocode.py
│   │
│   ├── scoring/
│   │   ├── clustering.py
│   │   ├── priority_score.py
│   │   └── run_scoring.py
│   │
│   ├── data/
│   │   └── deprivation_index.json
│   │
│   └── seed/
│       └── seed_requests.py
│
├── docs/
│   └── architecture.png
│
├── README.md
└── ...
```

---

# ☁️ Deployment

## Backend — Render

Create a new **Web Service** pointing to:

```text
backend/
```

### Build command

```bash
pip install -r requirements.txt
```

### Start command

```bash
uvicorn main:app --host 0.0.0.0 --port $PORT
```

Configure the required environment variables in Render.

After deployment, verify:

```text
https://<your-render-service>/docs
```

and:

```text
https://<your-render-service>/api/hotspots
```

---

## Frontend — Vercel

Deploy:

```text
frontend/
```

to Vercel.

Configure the frontend's backend/API URL to point to the deployed Render service.

The final application exposes:

```text
https://<your-vercel-app>/citizen
https://<your-vercel-app>/dashboard
```

The **Vercel URL is the single working prototype link**.

---

# 🔬 What's real vs. prototype-scoped

| Component                      | Current implementation             |
| ------------------------------ | ---------------------------------- |
| Voice transcription            | Whisper with fallback              |
| Language detection             | Pipeline implementation            |
| Classification                 | Keyword-based prototype classifier |
| Geocoding                      | Nominatim / OpenStreetMap          |
| Geographic clustering          | DBSCAN                             |
| Priority scoring               | Transparent weighted formula       |
| Dashboard                      | React + Leaflet + Recharts         |
| Database                       | MongoDB                            |
| Deprivation data               | Static illustrative seed table     |
| Scheme alignment               | Static lookup table                |
| WhatsApp / IVR / SMS           | Not directly integrated            |
| Production government datasets | Not yet connected                  |

### Important data note

The current deprivation index is **illustrative prototype data**, not an official government dataset.

Likewise, scheme alignment currently uses a static lookup rather than a live government scheme database.

These are deliberate prototype choices so that the complete architecture can be demonstrated without depending on external government data availability.

---

# 🛣️ Next steps

JanSetu is designed so prototype components can be replaced incrementally.

### Phase 1 — Prototype

* Synthetic data
* Static deprivation index
* Static scheme mapping
* Keyword classification
* One Vercel deployment
* One Render backend

### Phase 2 — Real-world pilot

* Official deprivation datasets
* Live government scheme metadata
* Improved multilingual classification
* More districts
* Better geocoding and locality resolution
* Authentication and role-based policymaker access

### Phase 3 — Multi-channel deployment

```text
WhatsApp
   │
IVR ──┐
      │
SMS ──┼──→ POST /api/requests
      │
Web ──┘
          │
          ▼
      JanSetu
```

The core ingestion API remains the common interface.

---

# 🔐 Privacy & responsible deployment

The current hackathon prototype uses synthetic data.

A production deployment would require additional safeguards, including:

* consent and appropriate notice for citizen submissions,
* protection of personally identifiable information,
* authentication and authorization,
* rate limiting and abuse prevention,
* secure handling of uploaded audio,
* retention and deletion policies,
* monitoring for geocoding/classification errors,
* human review before funding or administrative decisions.

**JanSetu is intended to support policy prioritization, not make autonomous funding decisions.**

---

# 🏆 Hackathon demo

The intended demo takes roughly **60–90 seconds**:

```text
1. Open /citizen
        ↓
2. Submit a voice complaint
        ↓
3. Show the structured request
        ↓
4. Recompute hotspots
        ↓
5. Open /dashboard
        ↓
6. Show the hotspot appearing in the ranked list
        ↓
7. Show the explanation behind its score
```

The key moment:

> **A messy citizen complaint becomes a geographic, scored and explainable policy signal.**

---

**Prototype:** `http://jansetu-kappa.vercel.app`

**Repository:** `https://github.com/sambhavi0/Jansetu`

---

## Built with

**React • Vite • FastAPI • LangGraph • Whisper • MongoDB • scikit-learn • Leaflet • Recharts • Nominatim / OpenStreetMap**

---

### One-line description

> **JanSetu turns multilingual citizen infrastructure reports into geographically clustered, scored, and explainable priority hotspots for policymakers.**
