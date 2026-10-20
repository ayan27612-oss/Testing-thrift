# Weiren Thrifts

An editorial storefront for a curated Indian thrift clothing brand, built with Next.js, React, TypeScript, and CSS design tokens.

## Current status

The initial storefront is committed on `main`. It includes a responsive homepage, category browsing, search, sorting, product quick view, local wishlist/cart persistence, and a persistent light/dark theme. The visible catalog is demonstration content only. The cart deliberately does not create orders or claim payment success.

## Run locally

1. Install Node.js 20.9+.
2. Run `npm install`.
3. Copy `.env.example` to `.env.local` and fill in your own Supabase project values when configured.
4. Run `npm run dev` and open http://localhost:3000.
5. Run `npm run build` before deployment.

## Supabase and payments

No Supabase project was connected/available at initial inspection. Create or select the correct project before applying migrations. Never put a service-role key in browser code. The sample catalog is hard-coded and must be replaced with real, verified inventory before launch. Product imagery currently uses remote Unsplash editorial placeholders and must not be represented as photographs of actual items.

Before real orders: add database migrations and RLS policies; implement server-side inventory locking and order totals; configure Supabase Auth; integrate a supported payment provider; verify payment webhooks; add fulfillment and refund workflows; and publish accurate shipping, returns, privacy, and contact details. Vercel environment variables must be configured through the project settings once the Vercel project is linked.

## Repository and deployment

Repository: https://github.com/ayan27612-oss/Testing-thrift
Default branch: `main`. Vercel currently reports no project associated with this repository. Supabase currently reports no available projects in the connected account. The application is not yet deployed.
