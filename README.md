# Professor Portal — Setup Guide

A complete academic portfolio & management system.
- **Admin Portal**: Manage all your content (private)
- **Public Portfolio**: Shareable page for students & collaborators

---

## 🗂 Project Structure

```
professor-portal/
├── admin/
│   ├── login.html          ← Login page
│   └── index.html          ← Admin dashboard (all management)
├── portfolio/
│   └── index.html          ← Public shareable portfolio
├── assets/
│   ├── css/
│   │   ├── admin.css       ← Admin styles
│   │   └── portfolio.css   ← Portfolio styles
│   └── js/
│       └── supabase.js     ← All Supabase functions
├── supabase_schema.sql     ← Run this in Supabase SQL Editor
├── netlify.toml            ← Netlify deployment config
└── vercel.json             ← Vercel deployment config
```

---

## ⚡ Step 1: Supabase Setup

1. Go to [supabase.com](https://supabase.com) → Create a free account
2. Click **"New Project"** → Give it a name → Create
3. Wait ~2 minutes for it to initialize
4. Go to **SQL Editor** (left sidebar) → **New Query**
5. Open `supabase_schema.sql`, copy everything, paste it in, click **Run**
6. Go to **Settings → API** and copy:
   - **Project URL** (looks like `https://xxxx.supabase.co`)
   - **anon/public key** (the long `eyJ...` key)

---

## 🔑 Step 2: Add Your Credentials

Open `assets/js/supabase.js` and replace these two lines at the top:

```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';       // paste your URL here
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY'; // paste your key here
```

---

## 👤 Step 3: Create Your Login

1. In Supabase dashboard → **Authentication → Users**
2. Click **"Add user"** → Enter your email and password
3. That's it! Use those credentials to log in at `/admin/login.html`

---

## 🚀 Step 4: Deploy to Netlify

### Option A — Drag and Drop (Easiest)
1. Go to [netlify.com](https://netlify.com) → Sign up (free)
2. From your dashboard click **"Add new site → Deploy manually"**
3. Drag your entire `professor-portal` folder into the upload area
4. Done! You'll get a URL like `https://random-name.netlify.app`

### Option B — From GitHub (Recommended for updates)
1. Push this folder to a GitHub repository
2. In Netlify: **"Add new site → Import from Git"**
3. Connect your GitHub → Select the repo
4. Build settings: leave blank (it's static HTML)
5. Deploy!

---

## 🚀 Deploy to Vercel (Alternative)

1. Push to GitHub
2. Go to [vercel.com](https://vercel.com) → **"Add New Project"**
3. Import your GitHub repo
4. Framework: **Other** (Static)
5. Deploy

---

## 🔗 Your URLs After Deployment

| Page | URL |
|------|-----|
| **Public Portfolio** | `https://your-site.netlify.app/` |
| **Admin Login** | `https://your-site.netlify.app/admin/login.html` |
| **Admin Dashboard** | `https://your-site.netlify.app/admin/index.html` |

**Share the Portfolio URL** with students and colleagues.
**Keep the Admin URL** to yourself.

---

## 📋 Admin Dashboard Features

| Section | What You Can Do |
|---------|-----------------|
| **Dashboard** | Overview stats, recent content |
| **My Profile** | Name, bio, photo, contact info, bilingual (English/Urdu) |
| **Lectures** | Add YouTube lecture videos with categories |
| **Publications** | Journal/conference papers with status |
| **Courses** | Course listings with codes and semesters |
| **Blog** | Write and publish articles |
| **CV/Resume** | Upload PDF, auto-links to portfolio |
| **Contact Info** | Edit public contact details |

---

## 📱 Notes for Flutter Developer

Since you're a Flutter dev:
- This is plain **HTML + CSS + JavaScript** (no frameworks)
- Supabase is similar to Firebase — same concept, open source
- The `assets/js/supabase.js` file = your "repository layer"
- Each function (`getLectures()`, `upsertProfile()`) = equivalent to a Flutter service class
- The auth flow is: Login → `signIn()` → Supabase returns session → stored in localStorage automatically

---

## 🛠 Customization Tips

**Change colors**: Edit `assets/css/admin.css` and `portfolio.css`, look for `:root { --navy: ... --gold: ... }`

**Add more fields**: Add columns in Supabase SQL, then add input fields in `admin/index.html` and display them in `portfolio/index.html`

**Custom domain**: In Netlify/Vercel → Domain settings → Add your domain

---

## ❓ Common Issues

**"Supabase not defined"**: Check that your URL and Key are correctly pasted in `supabase.js`

**Login fails**: Make sure you created a user in Supabase Auth → Users

**Data not showing**: Open browser DevTools (F12) → Console → check for errors. Most likely the Supabase credentials are wrong.

**Photos not showing**: Make sure the `avatars` bucket was created (run the SQL schema again)
