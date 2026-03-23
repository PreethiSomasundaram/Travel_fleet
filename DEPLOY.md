# Render Deployment Guide

This project uses a monorepo structure with both backend (Node.js) and Flutter app in the same repository. Only the backend is deployed to Render.

## Prerequisites

1. **Render Account**: Create a free account at [render.com](https://render.com)
2. **GitHub Repository**: Push this repo to GitHub
3. **Environment Variables**: Prepare the following variables:
   - `MONGO_URI` - MongoDB connection string
   - `JWT_SECRET` - JWT secret key
   - `FIREBASE_PROJECT_ID` - Firebase project ID
   - `FIREBASE_PRIVATE_KEY` - Firebase private key
   - `FIREBASE_CLIENT_EMAIL` - Firebase client email
   - `FIREBASE_DATABASE_URL` - Firebase database URL

## Deployment Steps

### Option 1: Using render.yaml (Recommended)

1. Go to [https://dashboard.render.com](https://dashboard.render.com)
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository
4. Select the repository
5. Render will auto-detect `render.yaml` configuration
6. Review the settings and click **"Deploy"**
7. Add environment variables in the Render dashboard:
   - Go to your service → **Settings** → **Environment**
   - Add each variable from the Prerequisites section

### Option 2: Manual Configuration (Dashboard)

1. Go to [https://dashboard.render.com](https://dashboard.render.com)
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository
4. Configure the following:
   - **Name**: `travel-fleet-backend`
   - **Environment**: `Node`
   - **Build Command**: `cd backend && npm install`
   - **Start Command**: `cd backend && npm start`
   - **Plan**: Free or Starter (as per requirement)
5. Click **"Create Web Service"**
6. Once created, go to **Settings** → **Environment** and add all required variables
7. Click **"Deploy"** to start deployment

## Environment Variables

Add these in Render Dashboard (Settings → Environment):

| Variable | Example | Required |
|----------|---------|----------|
| `NODE_ENV` | `production` | Yes |
| `MONGO_URI` | `mongodb+srv://user:pass@cluster.mongodb.net/db` | Yes |
| `JWT_SECRET` | Any secure string | Yes |
| `FIREBASE_PROJECT_ID` | Your Firebase project ID | Yes |
| `FIREBASE_PRIVATE_KEY` | Your Firebase private key | Yes |
| `FIREBASE_CLIENT_EMAIL` | Your Firebase service account email | Yes |
| `FIREBASE_DATABASE_URL` | Your Firebase database URL | Yes |

## Verify Deployment

Once deployed, you can verify the API is working:

```bash
curl https://<your-render-app>.onrender.com/health
# Expected response: {"status":"ok","service":"travel-fleet-backend"}
```

## Updating Deployment

Any push to your GitHub repository will automatically trigger a new deployment (if auto-deploy is enabled in Render settings).

To manually redeploy:
1. Go to your service on Render Dashboard
2. Click **"Deploy"** button in the top right

## Troubleshooting

- **Build fails**: Check that `package.json` exists in the `backend/` directory
- **App crashes**: Check logs in Render Dashboard → Service → Logs
- **Environment variables not found**: Ensure variables are added in Settings → Environment
- **Database connection fails**: Verify `MONGO_URI` is correct and MongoDB is accessible
- **Firebase issues**: Double-check Firebase credentials and that they match your project

## Local Development

To test locally before deploying:

```bash
cd backend
cp .env.example .env
# Edit .env with your credentials
npm install
npm run dev
```

The server will run on `http://localhost:5000`
