-- Weiren Thrifts initial schema. Review and apply only to the intended Supabase project.
create extension if not exists pgcrypto;

create type public.product_condition as enum ('like_new','excellent','good','fair');
create type public.order_status as enum ('pending','paid','processing','shipped','delivered','cancelled','refunded');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.admin_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin','fulfillment')),
  created_at timestamptz not null default now()
);
create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  slug text not null unique,
  description text,
  created_at timestamptz not null default now()
);
create table public.collections (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  description text,
  cover_image_url text,
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);
create table public.products (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  description text not null default '',
  category_id uuid references public.categories(id) on delete set null,
  brand text,
  price_paise integer not null check (price_paise >= 0),
  compare_at_price_paise integer check (compare_at_price_paise is null or compare_at_price_paise >= price_paise),
  label_size text,
  color text,
  material text,
  condition public.product_condition not null,
  condition_notes text not null default '',
  visible_flaws text not null default '',
  care_instructions text,
  inventory_count integer not null default 1 check (inventory_count >= 0),
  is_unique boolean not null default true,
  is_featured boolean not null default false,
  is_published boolean not null default false,
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index products_published_created_idx on public.products (is_published, created_at desc);
create index products_category_idx on public.products (category_id);
create table public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  image_url text not null,
  alt_text text not null default '',
  sort_order integer not null default 0,
  is_primary boolean not null default false,
  created_at timestamptz not null default now()
);
create index product_images_product_sort_idx on public.product_images (product_id, sort_order);
create table public.product_measurements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null unique references public.products(id) on delete cascade,
  chest_cm numeric(6,2), shoulder_cm numeric(6,2), length_cm numeric(6,2), sleeve_cm numeric(6,2),
  waist_cm numeric(6,2), rise_cm numeric(6,2), inseam_cm numeric(6,2), leg_opening_cm numeric(6,2),
  notes text,
  updated_at timestamptz not null default now()
);
create table public.collection_products (
  collection_id uuid not null references public.collections(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  sort_order integer not null default 0,
  primary key (collection_id, product_id)
);
create table public.wishlist_items (
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, product_id)
);
create table public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  recipient_name text not null,
  phone text not null,
  address_line1 text not null,
  address_line2 text,
  city text not null,
  state text not null,
  postal_code text not null check (postal_code ~ '^[0-9]{6}$'),
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);
create table public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique default ('WT-' || upper(substr(replace(gen_random_uuid()::text,'-',''),1,10))),
  user_id uuid references auth.users(id) on delete set null,
  email text not null,
  phone text,
  status public.order_status not null default 'pending',
  currency text not null default 'INR' check (currency = 'INR'),
  subtotal_paise integer not null check (subtotal_paise >= 0),
  shipping_paise integer not null default 0 check (shipping_paise >= 0),
  total_paise integer not null check (total_paise >= 0),
  shipping_address jsonb not null,
  payment_provider text,
  provider_order_id text,
  tracking_number text,
  tracking_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index orders_user_created_idx on public.orders (user_id, created_at desc);
create table public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  product_slug text not null,
  image_url text,
  label_size text,
  unit_price_paise integer not null check (unit_price_paise >= 0),
  quantity integer not null check (quantity > 0),
  condition_snapshot text not null,
  unique (order_id, product_id)
);
create table public.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  provider text not null,
  provider_payment_id text unique,
  provider_order_id text,
  amount_paise integer not null check (amount_paise >= 0),
  status text not null check (status in ('created','pending','authorized','captured','failed','refunded')),
  webhook_event_id text unique,
  verified_at timestamptz,
  created_at timestamptz not null default now()
);
create table public.newsletter_subscriptions (
  id uuid primary key default gen_random_uuid(),
  email text not null unique check (email = lower(email)),
  consented_at timestamptz not null default now(),
  unsubscribed_at timestamptz
);

create or replace function public.is_store_admin()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.admin_roles where user_id = (select auth.uid()) and role in ('admin','fulfillment'));
$$;

alter table public.profiles enable row level security;
alter table public.admin_roles enable row level security;
alter table public.categories enable row level security;
alter table public.collections enable row level security;
alter table public.products enable row level security;
alter table public.product_images enable row level security;
alter table public.product_measurements enable row level security;
alter table public.collection_products enable row level security;
alter table public.wishlist_items enable row level security;
alter table public.addresses enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.payments enable row level security;
alter table public.newsletter_subscriptions enable row level security;

create policy "Published categories are readable" on public.categories for select using (true);
create policy "Published collections are readable" on public.collections for select using (is_published or public.is_store_admin());
create policy "Published products are readable" on public.products for select using ((is_published and inventory_count >= 0) or public.is_store_admin());
create policy "Product images follow product visibility" on public.product_images for select using (exists (select 1 from public.products p where p.id = product_id and (p.is_published or public.is_store_admin())));
create policy "Measurements follow product visibility" on public.product_measurements for select using (exists (select 1 from public.products p where p.id = product_id and (p.is_published or public.is_store_admin())));
create policy "Collection products follow collection visibility" on public.collection_products for select using (exists (select 1 from public.collections c where c.id = collection_id and (c.is_published or public.is_store_admin())));
create policy "Users read own profile" on public.profiles for select using (id = (select auth.uid()) or public.is_store_admin());
create policy "Users update own profile" on public.profiles for update using (id = (select auth.uid())) with check (id = (select auth.uid()));
create policy "Users insert own profile" on public.profiles for insert with check (id = (select auth.uid()));
create policy "Users manage own wishlist" on public.wishlist_items for all using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "Users manage own addresses" on public.addresses for all using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "Users read own orders" on public.orders for select using (user_id = (select auth.uid()) or public.is_store_admin());
create policy "Users read own order items" on public.order_items for select using (exists (select 1 from public.orders o where o.id = order_id and (o.user_id = (select auth.uid()) or public.is_store_admin())));
create policy "Admins read payments" on public.payments for select using (public.is_store_admin());
create policy "Admins read roles" on public.admin_roles for select using (user_id = (select auth.uid()) or public.is_store_admin());
create policy "Admins manage categories" on public.categories for all using (public.is_store_admin()) with check (public.is_store_admin());
create policy "Admins manage collections" on public.collections for all using (public.is_store_admin()) with check (public.is_store_admin());
create policy "Admins manage products" on public.products for all using (public.is_store_admin()) with check (public.is_store_admin());
create policy "Admins manage product images" on public.product_images for all using (public.is_store_admin()) with check (public.is_store_admin());
create policy "Admins manage measurements" on public.product_measurements for all using (public.is_store_admin()) with check (public.is_store_admin());
create policy "Admins manage collection products" on public.collection_products for all using (public.is_store_admin()) with check (public.is_store_admin());
create policy "Admins manage orders" on public.orders for update using (public.is_store_admin()) with check (public.is_store_admin());
create policy "Admins manage order items" on public.order_items for all using (public.is_store_admin()) with check (public.is_store_admin());
create policy "Admins manage payments" on public.payments for all using (public.is_store_admin()) with check (public.is_store_admin());
create policy "Public can subscribe to newsletter" on public.newsletter_subscriptions for insert with check (true);
create policy "Admins manage newsletter" on public.newsletter_subscriptions for select using (public.is_store_admin());

-- IMPORTANT: no client-side insert policy is provided for orders/payments. Create orders via a trusted server endpoint/RPC
-- that recalculates prices and atomically reserves stock; verify payment webhooks before transitioning orders to paid.
