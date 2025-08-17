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