# Solicitações APP

[Flutter](https://flutter.dev)  
[Dart](https://dart.dev)  
[FastAPI](https://fastapi.tiangolo.com/)  
[Python](https://www.python.org/)  
[Supabase](https://supabase.com/)  
[Render](https://render.com/)

A complete solution for urban request management aimed at municipalities, connecting citizens and public administration quickly, transparently, and efficiently.

---

**HEIMDALL SOLUTIONS**

## About the Project

The **Solicitações APP** was developed to modernize and simplify the opening, tracking, and resolution of municipal public demands. The application combines the flexibility of mobile development with a scalable, low-cost cloud infrastructure, eliminating dependence on physical servers and simplifying maintenance.

---

## Video Demo and Web Page

Check out the app in action:

(IN DEVELOPMENT)  
YouTube Demo: https://youtube.com  

**WEB PAGE LINK**: https://gabrielhencastro.github.io/SolicitacoesLandingPage

---

## Technologies and Architecture

The project ecosystem is divided into three main layers:

### Front-End & Mobile
* **Mobile App:** Built with **Flutter & Dart**, offering a native, responsive, and intuitive experience for citizens.  
* **Landing Page Web:** Developed with **HTML5, CSS3, JavaScript, and Bootstrap** to present the project and guide users.

### Back-End & Processing
* **FastAPI (Python):** RESTful API server hosted in the cloud via **Render**, focused on high performance and low response time.  
* **Pandas & FPDF:** Modules dedicated to heavy data processing and automated generation of analytical reports in PDF format for public management.

### Database & BaaS
* **Supabase (PostgreSQL):** Used as Backend-as-a-Service for:  
  * Cloud relational database with high scalability.  
  * Fast and secure authentication via Flutter SDK.  
  * File and image storage attached to requests (*Storage*).  
  * Security with ROW LEVEL SECURITY (RLS).  

---

## Main Features

- **Request Submission:** Register municipal occurrences with photo, description, and location.  
- **Secure Authentication:** User login and registration integrated with Supabase Auth.  
- **Report Generation:** Automated management reports in PDF via Python backend.  
- **100% Serverless/Cloud Architecture:** No dependency on local physical hardware.  

---

## Related Repositories

| Component | Repository / Status |
| :--- | :--- |
| **API REST (Python / FastAPI)** | https://github.com/gabrielhencastro/SolicitacoesApi |
| **LANDING PAGE WEB** | https://github.com/gabrielhencastro/SolicitacoesLandingPage |

---

## How to Run the Mobile Project

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install) installed and configured.  
* [Git](https://git-scm.com/) installed.  
* Account on [Supabase](https://supabase.com/) configured.  

### Steps to Run

1. **Clone this repository:**
   ```bash
   git clone https://github.com/gabrielhencastro/solicitacoes_app.git
   cd solicitacoes_app
   ```

2. **Check how to configure the API in the previously presented repository.**

3. **Set environment variables:**
  ```env
  SUPABASE_URL = ...
  PUBLISHABLE_KEY = ...
  URL_API = ...
  ```
4. **Run the app**