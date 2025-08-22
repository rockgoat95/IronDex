-- Users
create table users (
    id uuid primary key references auth.users(id) on delete cascade,
    username text not null,
    role text check (role in ('user','admin')) default 'user',
    created_at timestamp default now()
);

-- Brands
create table brands (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    country text,
    logo_url text,          -- 단일 로고 이미지 URL
    images text[],          -- 필요시 추가 이미지 다중 URL
    status text check (status in ('approved','pending')) default 'pending',
    created_by uuid references users(id),
    created_at timestamp default now()
);

-- Machines
create table machines (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    brand_id uuid references brands(id),
    description text,
    score float,
    line text,
    body_parts text[],        -- {"Chest","Shoulder"}
    movements text[],         -- {"Press","Extension"}
    type text,                -- "Selectorized", "Plate-loaded", "Cable" 등
    image_url text,           -- 대표 이미지 URL
    images text[],            -- 추가 이미지 다중 URL
    status text check (status in ('approved','pending')) default 'pending',
    created_by uuid references users(id),
    created_at timestamp default now()
);

-- Gyms
create table gyms (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    location text,
    score float,
    image_url text,           -- 대표 이미지 URL
    images text[],            -- 추가 이미지 다중 URL
    status text check (status in ('approved','pending')) default 'pending',
    created_by uuid references users(id),
    created_at timestamp default now()
);

-- GymMachines
create table gym_machines (
    gym_id uuid references gyms(id),           -- 헬스장은 삭제 안함
    machine_id uuid references machines(id),   -- 머신도 삭제 안함
    added_by uuid references users(id),        -- 유저 삭제 가능, NULL 처리 가능
    status text check (status in ('approved','pending')) default 'pending',
    created_at timestamp default now(),
    primary key (gym_id, machine_id)
);

-- Machine Reviews
create table machine_reviews (
    id uuid primary key default gen_random_uuid(),
    machine_id uuid references machines(id),   -- 머신 삭제 안함
    user_id uuid references users(id),         -- 유저 삭제 가능, NULL 처리
    rating int check (rating >= 1 and rating <= 5),
    comment text,
    created_at timestamp default now()
);

-- Brand Reviews
create table brand_reviews (
    id uuid primary key default gen_random_uuid(),
    brand_id uuid references brands(id),       -- 브랜드 삭제 안함
    user_id uuid references users(id),         -- 유저 삭제 가능, NULL 처리
    rating int check (rating >= 1 and rating <= 5),
    comment text,
    created_at timestamp default now()
);

-- Gym Reviews
create table gym_reviews (
    id uuid primary key default gen_random_uuid(),
    gym_id uuid references gyms(id),           -- 헬스장 삭제 안함
    user_id uuid references users(id),         -- 유저 삭제 가능, NULL 처리
    rating int check (rating >= 1 and rating <= 5),
    comment text,
    created_at timestamp default now()
);



-- Example Data Insertion

-- Insert Users
insert into users (id, username, role) values
  ('33333333-3333-3333-3333-333333333333', 'admin_user', 'admin'),
  ('44444444-4444-4444-4444-444444444444', 'regular_user', 'user');

-- Insert Brands
insert into brands (id, name, country, logo_url, created_by) values
  ('33333333-3333-3333-3333-333333333333', 'Hammer Strength', 'USA', 'https://example.com/logo_a.png', '33333333-3333-3333-3333-333333333333'),
  ('44444444-4444-4444-4444-444444444444', 'Gym80', 'Germany', 'https://example.com/logo_b.png', '33333333-3333-3333-3333-333333333333');

-- Insert Machines
insert into machines (id, name, brand_id, description, score, body_parts, movements, type, image_url, created_by) values
  ('55555555-5555-5555-5555-555555555555', 'Machine A', '33333333-3333-3333-3333-333333333333', 'Chest press machine', 4.5, '{Chest}', '{Press}', 'Selectorized', 'https://example.com/machine_a.png', '33333333-3333-3333-3333-333333333333'),
  ('66666666-6666-6666-6666-666666666666', 'Machine B', '44444444-4444-4444-4444-444444444444', 'Leg extension machine', 4.2, '{Legs}', '{Extension}', 'Plate-loaded', 'https://example.com/machine_b.png', '33333333-3333-3333-3333-333333333333');

-- Insert Gyms
insert into gyms (id, name, location, score, image_url, created_by) values
  ('77777777-7777-7777-7777-777777777777', 'Gym A', 'New York', 4.8, 'https://example.com/gym_a.png', '33333333-3333-3333-3333-333333333333'),
  ('88888888-8888-8888-8888-888888888888', 'Gym B', 'Berlin', 4.6, 'https://example.com/gym_b.png', '33333333-3333-3333-3333-333333333333');

-- Insert Gym Machines
insert into gym_machines (gym_id, machine_id, added_by) values
  ('77777777-7777-7777-7777-777777777777', '55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333'),
  ('88888888-8888-8888-8888-888888888888', '66666666-6666-6666-6666-666666666666', '33333333-3333-3333-3333-333333333333');

-- Insert Machine Reviews
insert into machine_reviews (id, machine_id, user_id, rating, comment) values
  ('99999999-9999-9999-9999-999999999999', '55555555-5555-5555-5555-555555555555', '44444444-4444-4444-4444-444444444444', 5, 'Great machine!'),
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '66666666-6666-6666-6666-666666666666', '44444444-4444-4444-4444-444444444444', 4, 'Good for leg workouts.');

-- Insert Brand Reviews
insert into brand_reviews (id, brand_id, user_id, rating, comment) values
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', '33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', 5, 'Excellent brand!'),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', '44444444-4444-4444-4444-444444444444', '44444444-4444-4444-4444-444444444444', 4, 'Reliable equipment.');

-- Insert Gym Reviews
insert into gym_reviews (id, gym_id, user_id, rating, comment) values
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', '77777777-7777-7777-7777-777777777777', '44444444-4444-4444-4444-444444444444', 5, 'Amazing gym!'),
  ('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', '88888888-8888-8888-8888-888888888888', '44444444-4444-4444-4444-444444444444', 4, 'Great facilities.');

