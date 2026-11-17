# FUJI TRAVEL JOURNAL

Tokyo Winter Escape · 2026/12/26–2027/01/14

A responsive, no-AI travel journal for two people. Built with HTML, CSS and vanilla JavaScript so it can be hosted as a static GitHub Pages site.

## Features

- Editable day-by-day itinerary (add, edit, delete and reorder by time)
- Restaurant search near a selected Tokyo district using OpenStreetMap; Google Maps navigation links
- Nearby discovery using OpenStreetMap Nominatim + Overpass
- Interactive Leaflet map with saved itinerary and restaurant markers
- Tokyo / Hakone weather from Open-Meteo (forecast appears only when dates are within the provider's forecast range)
- JPY expense log, shared-expense tagging and CSV export
- Tickets, checklist, accommodation details and travel journal
- Local persistence and JSON backup / restore
- Optional two-person cloud sync using Supabase Auth + Realtime
- Installable PWA shell and cached core files for offline viewing

## Run locally

No build step is required.

1. Clone the repository.
2. Open `index.html` in a local web server (recommended) or use VS Code Live Server.
3. For GPS location and service worker features, use HTTPS or localhost.

## GitHub Pages

A GitHub Actions workflow is included at `.github/workflows/deploy.yml`.

1. Open repository **Settings → Pages**.
2. Set the build and deployment source to **GitHub Actions** (if it is not already selected).
3. Push to `main`; the workflow publishes the site.
4. The website URL will be `https://pccc-pc.github.io/tokeyo/`.

## Two-person sync (Supabase)

The website works in local-only mode without Supabase. To share one trip between two separate accounts:

1. Create a Supabase project.
2. In Supabase **SQL Editor**, run the full script in `supabase/schema.sql`.
3. In Supabase **Project Settings → API**, copy the Project URL and the public anon / publishable key. Never use the service-role key in the browser.
4. Open the website → gear icon → enter the URL and public key → Save.
5. Reopen Settings. Register or sign in with your own email and password.
6. Select **建立共享旅行**. The website creates a trip and displays an invite code.
7. Your partner opens the same website, enters the same Supabase URL and public key, registers/signs in with their own account, enters the invite code and selects **加入旅行**.
8. Both accounts now read and update the same trip document. Realtime updates are delivered through Supabase Realtime.

The Supabase database is private to authenticated trip members through Row Level Security. The public anon key is designed for browser use when RLS is correctly configured. Do not publish a service-role key.

### Current sync model

The first implementation syncs the travel workspace as one JSON document in `travel_trips.trip_data`. This is simple to operate for a two-person trip. When both people edit at exactly the same time, the latest saved document can replace the other change; avoid editing the same field simultaneously. A later iteration can split the document into individual tables and add field-level conflict resolution.

## Local storage and backups

- Without Supabase, edits are saved in the current browser's local storage.
- Local storage does not sync between different phones or browsers.
- Use Settings → **匯出 JSON 備份** to download a backup.
- Use Settings → **匯入 JSON** to restore a backup.
- Expense records can be exported separately as CSV.

## Search and map data

- Food search and nearby discovery use OpenStreetMap Nominatim for geocoding and the Overpass API for nearby restaurant/place features.
- Restaurant search opens Google Maps search results. Save a selected place through the manual restaurant form.
- Maps use Leaflet and OpenStreetMap tiles.
- Weather uses Open-Meteo.
- These public services have usage limits and depend on network availability. The app does not fabricate ratings, opening hours, route times or live transport fares.

## Notes / known limitations

- The flight numbers and terminal numbers were not provided, so editable fields are still needed.
- The accommodation street address is not provided; Kiba Station is used as the planning base.
- The itinerary includes unverified opening hours and activity details; check official 2027 holiday notices before travel.
- The Tokyo Disney / attraction pass validity and venue-specific entry conditions must be checked in the pass app on the visit dates.
- The current map displays place markers and Google Maps navigation links. It does not invent rail routes or live transit directions.
- Nearby results depend on OpenStreetMap coverage; not every Japanese business has complete tags.
- Weather forecasts for dates outside Open-Meteo's forecast horizon are shown as not yet available.
- PWA offline support caches the app shell; live search, weather, map tiles and cloud sync still require a network connection.

## Project files

- `index.html` — application structure
- `style.css` — Fuji winter oil-paint palette and responsive layout
- `app.js` — itinerary, local data, map, nearby search, weather, budgets and Supabase sync
- `manifest.webmanifest` — installable PWA metadata
- `sw.js` — offline app-shell cache
- `supabase/schema.sql` — shared-trip database, RLS and invite-code RPCs
