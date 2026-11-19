-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "VerificationStatus" AS ENUM ('PENDING', 'VERIFIED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ListingStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'RENTED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "OrderStatus" AS ENUM ('PENDING', 'PAID', 'COMPLETED', 'CANCELLED', 'REFUNDED');

-- CreateTable
CREATE TABLE "User" (
    "id" UUID NOT NULL,
    "displayName" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Community" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "province" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "district" TEXT NOT NULL,
    "address" TEXT,
    "latitude" DECIMAL(10,7),
    "longitude" DECIMAL(10,7),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Community_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RentRecord" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "communityId" UUID NOT NULL,
    "monthlyRent" INTEGER NOT NULL,
    "areaSqm" DECIMAL(8,2) NOT NULL,
    "bedrooms" INTEGER NOT NULL,
    "leaseStartedAt" DATE NOT NULL,
    "evidenceSha256" CHAR(64) NOT NULL,
    "redactedEvidenceKey" TEXT NOT NULL,
    "verificationStatus" "VerificationStatus" NOT NULL DEFAULT 'PENDING',
    "deviationPercent" DECIMAL(8,1),
    "reviewedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RentRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LandlordVerification" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "deedSha256" CHAR(64) NOT NULL,
    "verificationStatus" "VerificationStatus" NOT NULL DEFAULT 'PENDING',
    "originalDestroyedAt" TIMESTAMP(3),
    "verifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LandlordVerification_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Listing" (
    "id" UUID NOT NULL,
    "landlordId" UUID NOT NULL,
    "communityId" UUID NOT NULL,
    "landlordVerificationId" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "monthlyRent" INTEGER NOT NULL,
    "areaSqm" DECIMAL(8,2) NOT NULL,
    "bedrooms" INTEGER NOT NULL,
    "status" "ListingStatus" NOT NULL DEFAULT 'DRAFT',
    "publishedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Listing_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ServiceOrder" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "listingId" UUID NOT NULL,
    "serviceFeeFen" INTEGER NOT NULL DEFAULT 19900,
    "currency" CHAR(3) NOT NULL DEFAULT 'CNY',
    "status" "OrderStatus" NOT NULL DEFAULT 'PENDING',
    "paymentReference" TEXT,
    "electronicContractKey" TEXT,
    "contractSha256" CHAR(64),
    "paidAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ServiceOrder_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Community_city_district_idx" ON "Community"("city", "district");

-- CreateIndex
CREATE UNIQUE INDEX "Community_province_city_district_name_key" ON "Community"("province", "city", "district", "name");

-- CreateIndex
CREATE UNIQUE INDEX "RentRecord_evidenceSha256_key" ON "RentRecord"("evidenceSha256");

-- CreateIndex
CREATE INDEX "RentRecord_communityId_verificationStatus_leaseStartedAt_idx" ON "RentRecord"("communityId", "verificationStatus", "leaseStartedAt");

-- CreateIndex
CREATE INDEX "RentRecord_userId_idx" ON "RentRecord"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "LandlordVerification_deedSha256_key" ON "LandlordVerification"("deedSha256");

-- CreateIndex
CREATE INDEX "LandlordVerification_userId_verificationStatus_idx" ON "LandlordVerification"("userId", "verificationStatus");

-- CreateIndex
CREATE UNIQUE INDEX "LandlordVerification_id_userId_key" ON "LandlordVerification"("id", "userId");

-- CreateIndex
CREATE INDEX "Listing_communityId_status_idx" ON "Listing"("communityId", "status");

-- CreateIndex
CREATE INDEX "Listing_landlordVerificationId_landlordId_idx" ON "Listing"("landlordVerificationId", "landlordId");

-- CreateIndex
CREATE UNIQUE INDEX "ServiceOrder_paymentReference_key" ON "ServiceOrder"("paymentReference");

-- CreateIndex
CREATE INDEX "ServiceOrder_userId_status_idx" ON "ServiceOrder"("userId", "status");

-- CreateIndex
CREATE INDEX "ServiceOrder_listingId_idx" ON "ServiceOrder"("listingId");

-- AddForeignKey
ALTER TABLE "RentRecord" ADD CONSTRAINT "RentRecord_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RentRecord" ADD CONSTRAINT "RentRecord_communityId_fkey" FOREIGN KEY ("communityId") REFERENCES "Community"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LandlordVerification" ADD CONSTRAINT "LandlordVerification_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Listing" ADD CONSTRAINT "Listing_landlordId_fkey" FOREIGN KEY ("landlordId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Listing" ADD CONSTRAINT "Listing_communityId_fkey" FOREIGN KEY ("communityId") REFERENCES "Community"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Listing" ADD CONSTRAINT "Listing_landlordVerificationId_landlordId_fkey" FOREIGN KEY ("landlordVerificationId", "landlordId") REFERENCES "LandlordVerification"("id", "userId") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ServiceOrder" ADD CONSTRAINT "ServiceOrder_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ServiceOrder" ADD CONSTRAINT "ServiceOrder_listingId_fkey" FOREIGN KEY ("listingId") REFERENCES "Listing"("id") ON DELETE RESTRICT ON UPDATE CASCADE;


-- Fixed technical service fee: CNY 199, independent of monthly rent.
ALTER TABLE "ServiceOrder" ADD CONSTRAINT "ServiceOrder_fixed_fee" CHECK ("serviceFeeFen" = 19900 AND "currency" = 'CNY');
ALTER TABLE "RentRecord" ADD CONSTRAINT "RentRecord_positive_values" CHECK ("monthlyRent" > 0 AND "areaSqm" > 0 AND "bedrooms" >= 0);
ALTER TABLE "Listing" ADD CONSTRAINT "Listing_positive_values" CHECK ("monthlyRent" > 0 AND "areaSqm" > 0 AND "bedrooms" >= 0);
