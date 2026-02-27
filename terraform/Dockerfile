# ---------- Build Stage ----------
FROM node:18-alpine AS build

# Strapi requires these build-time dependencies on Alpine
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev > /dev/null 2>&1

WORKDIR /app

COPY package*.json ./
# Use npm ci for faster, more reliable builds in CI/CD
RUN npm ci

COPY . .

# Strapi build often needs a dummy or real JWT_SECRET to complete the build process
ENV NODE_ENV=production
RUN npm run build

# ---------- Production Stage ----------
FROM node:18-alpine

# Install runtime dependencies for VIPS (image processing)
RUN apk add --no-cache vips-dev

WORKDIR /app

ENV NODE_ENV=production

# Only copy the necessary files from build
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/public ./public
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/dist ./dist
# If you have a custom config folder:
COPY --from=build /app/config ./config

EXPOSE 1337

CMD ["npm", "start"]