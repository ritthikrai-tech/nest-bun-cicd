# --- Stage 1: Build ---
    FROM oven/bun:1 AS build

    WORKDIR /usr/src/app
    
    # Copy ไฟล์ package และ lock file (ของ bun จะเป็น bun.lock)
    COPY package.json bun.lock ./
    
    # Install dependencies ด้วย bun
    # --frozen-lockfile คือการ install ตาม lock file เป๊ะๆ (เหมือน npm ci)
    RUN bun install --frozen-lockfile
    
    # Copy code ทั้งหมด
    COPY . .
    
    # สั่ง Build (NestJS จะ build ออกมาที่ folder dist)
    RUN bun run build
    
    # --- Stage 2: Production ---
    FROM oven/bun:1 AS production
    
    WORKDIR /usr/src/app
    
    COPY package.json bun.lock ./
    
    # Install เฉพาะ production dependencies
    RUN bun install --frozen-lockfile --production
    
    # Copy ไฟล์ที่ build เสร็จแล้วจาก Stage 1
    COPY --from=build /usr/src/app/dist ./dist
    
    EXPOSE 3000
    
    # ใช้ Bun run ไฟล์ main.js ที่ถูก build แล้ว
    CMD ["bun", "dist/main.js"]