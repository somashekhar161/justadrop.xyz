CREATE TYPE "public"."application_status" AS ENUM('pending', 'approved', 'rejected');--> statement-breakpoint
CREATE TYPE "public"."cause" AS ENUM('animal_welfare', 'environmental', 'humanitarian', 'education', 'healthcare', 'poverty_alleviation', 'women_empowerment', 'child_welfare', 'elderly_care', 'disability_support', 'rural_development', 'urban_development', 'arts_culture', 'sports', 'technology', 'other');--> statement-breakpoint
CREATE TYPE "public"."document_type" AS ENUM('registration_certificate', '80G_certificate', '12A_certificate', 'PAN');--> statement-breakpoint
CREATE TYPE "public"."gender" AS ENUM('male', 'female', 'other', 'prefer_not_to_say');--> statement-breakpoint
CREATE TYPE "public"."moderation_priority" AS ENUM('low', 'medium', 'high', 'urgent');--> statement-breakpoint
CREATE TYPE "public"."moderation_status" AS ENUM('open', 'resolved', 'dismissed');--> statement-breakpoint
CREATE TYPE "public"."moderation_type" AS ENUM('user', 'event', 'ngo');--> statement-breakpoint
CREATE TYPE "public"."opportunity_mode" AS ENUM('onsite', 'remote', 'hybrid');--> statement-breakpoint
CREATE TYPE "public"."opportunity_status" AS ENUM('draft', 'active', 'completed', 'cancelled');--> statement-breakpoint
CREATE TYPE "public"."organization_member_role" AS ENUM('owner', 'admin', 'member');--> statement-breakpoint
CREATE TYPE "public"."organization_status" AS ENUM('pending', 'verified', 'rejected', 'suspended');--> statement-breakpoint
CREATE TABLE "moderation_monitoring" (
	"id" text PRIMARY KEY NOT NULL,
	"moderation_type" "moderation_type" NOT NULL,
	"reasons" text NOT NULL,
	"target_metadata" jsonb,
	"status" "moderation_status" DEFAULT 'open' NOT NULL,
	"priority" "moderation_priority" DEFAULT 'medium' NOT NULL,
	"reported_by" text NOT NULL,
	"assigned_to" text,
	"reviewed_by" text,
	"reviewed_at" timestamp,
	"resolution_notes" text,
	"closed_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "moderation_monitoring_resolution_notes_length_check" CHECK ("moderation_monitoring"."resolution_notes" IS NULL OR char_length("moderation_monitoring"."resolution_notes") <= 5000)
);
--> statement-breakpoint
CREATE TABLE "moderators" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"assigned_regions" text[] DEFAULT '{}',
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "moderators_user_id_unique" UNIQUE("user_id")
);
--> statement-breakpoint
CREATE TABLE "opportunities" (
	"id" text PRIMARY KEY NOT NULL,
	"ngo_id" text NOT NULL,
	"user_created_by" text NOT NULL,
	"user_updated_by" text,
	"title" text NOT NULL,
	"description" text NOT NULL,
	"cause_category_names" text[] DEFAULT '{}' NOT NULL,
	"required_skills" text[] DEFAULT '{}',
	"max_volunteers" integer,
	"min_volunteers" integer,
	"language_preference" text,
	"gender_preference" text,
	"start_date" timestamp,
	"end_date" timestamp,
	"start_time" text,
	"end_time" text,
	"status" "opportunity_status" DEFAULT 'draft' NOT NULL,
	"opportunity_mode" "opportunity_mode" NOT NULL,
	"osrm_link" text,
	"address" text,
	"city" text,
	"state" text,
	"country" text DEFAULT 'India',
	"contact_name" text NOT NULL,
	"contact_phone_number" text,
	"contact_email" text NOT NULL,
	"stipend_info" jsonb,
	"is_certificate_offered" boolean DEFAULT false NOT NULL,
	"banner_image" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "volunteers_count_check" CHECK (("opportunities"."min_volunteers" IS NULL OR "opportunities"."max_volunteers" IS NULL OR "opportunities"."min_volunteers" <= "opportunities"."max_volunteers")),
	CONSTRAINT "date_range_check" CHECK (("opportunities"."start_date" IS NULL OR "opportunities"."end_date" IS NULL OR "opportunities"."start_date" <= "opportunities"."end_date")),
	CONSTRAINT "opportunities_description_length_check" CHECK (char_length("opportunities"."description") <= 10000)
);
--> statement-breakpoint
CREATE TABLE "opportunities_feedback" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"opportunity_id" text,
	"rating" integer NOT NULL,
	"images" text[] DEFAULT '{}',
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "opportunities_feedback_rating_check" CHECK ("opportunities_feedback"."rating" >= 1 AND "opportunities_feedback"."rating" <= 5)
);
--> statement-breakpoint
CREATE TABLE "opportunity_applications" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"opportunity_id" text NOT NULL,
	"motivation_description" text,
	"status" "application_status" DEFAULT 'pending' NOT NULL,
	"has_attended" boolean DEFAULT false NOT NULL,
	"approved_at" timestamp,
	"approved_by" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "applications_opp_user_unique" UNIQUE("opportunity_id","user_id")
);
--> statement-breakpoint
CREATE TABLE "organization_documents" (
	"id" text PRIMARY KEY NOT NULL,
	"ngo_id" text NOT NULL,
	"document_type" "document_type" NOT NULL,
	"document_asset_url" text NOT NULL,
	"format" text NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "organization_members" (
	"id" text PRIMARY KEY NOT NULL,
	"organization_id" text NOT NULL,
	"user_id" text NOT NULL,
	"role" "organization_member_role" DEFAULT 'member' NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"joined_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "organizations" (
	"id" text PRIMARY KEY NOT NULL,
	"created_by" text NOT NULL,
	"org_name" text NOT NULL,
	"description" text,
	"causes" text[] DEFAULT '{}' NOT NULL,
	"website" text,
	"registration_number" text,
	"contact_person_name" text NOT NULL,
	"contact_person_email" text NOT NULL,
	"contact_person_number" text,
	"verification_status" "organization_status" DEFAULT 'pending' NOT NULL,
	"address" text,
	"city" text,
	"state" text,
	"country" text DEFAULT 'India',
	"verified_at" timestamp,
	"logo" text,
	"year_established" text,
	"social_links" text[] DEFAULT '{}',
	"images" text[] DEFAULT '{}',
	"is_csr_eligible" boolean DEFAULT false NOT NULL,
	"is_fcra_registered" boolean DEFAULT false NOT NULL,
	"deleted_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "organizations_description_length_check" CHECK ("organizations"."description" IS NULL OR char_length("organizations"."description") <= 10000)
);
--> statement-breakpoint
CREATE TABLE "otp_tokens" (
	"id" text PRIMARY KEY NOT NULL,
	"email" text NOT NULL,
	"code" text NOT NULL,
	"expires_at" timestamp NOT NULL,
	"used" boolean DEFAULT false NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sessions" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"token" text NOT NULL,
	"expires_at" timestamp NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"last_accessed_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "sessions_token_unique" UNIQUE("token")
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" text PRIMARY KEY NOT NULL,
	"email" text NOT NULL,
	"email_verified" boolean DEFAULT false NOT NULL,
	"is_admin" boolean DEFAULT false NOT NULL,
	"name" text,
	"phone" text,
	"gender" "gender",
	"is_banned" boolean DEFAULT false NOT NULL,
	"volunteering" jsonb,
	"deleted_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
CREATE TABLE "volunteers_feedback" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text NOT NULL,
	"opportunity_id" text NOT NULL,
	"volunteer_id" text NOT NULL,
	"rating" integer NOT NULL,
	"testimonial" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "volunteers_feedback_rating_check" CHECK ("volunteers_feedback"."rating" >= 1 AND "volunteers_feedback"."rating" <= 5),
	CONSTRAINT "volunteers_feedback_testimonial_length_check" CHECK ("volunteers_feedback"."testimonial" IS NULL OR char_length("volunteers_feedback"."testimonial") <= 5000)
);
--> statement-breakpoint
ALTER TABLE "moderation_monitoring" ADD CONSTRAINT "moderation_monitoring_reported_by_users_id_fk" FOREIGN KEY ("reported_by") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "moderation_monitoring" ADD CONSTRAINT "moderation_monitoring_assigned_to_users_id_fk" FOREIGN KEY ("assigned_to") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "moderation_monitoring" ADD CONSTRAINT "moderation_monitoring_reviewed_by_users_id_fk" FOREIGN KEY ("reviewed_by") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "moderators" ADD CONSTRAINT "moderators_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "opportunities" ADD CONSTRAINT "opportunities_ngo_id_organizations_id_fk" FOREIGN KEY ("ngo_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "opportunities" ADD CONSTRAINT "opportunities_user_created_by_users_id_fk" FOREIGN KEY ("user_created_by") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "opportunities" ADD CONSTRAINT "opportunities_user_updated_by_users_id_fk" FOREIGN KEY ("user_updated_by") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "opportunities_feedback" ADD CONSTRAINT "opportunities_feedback_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "opportunities_feedback" ADD CONSTRAINT "opportunities_feedback_opportunity_id_opportunities_id_fk" FOREIGN KEY ("opportunity_id") REFERENCES "public"."opportunities"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "opportunity_applications" ADD CONSTRAINT "opportunity_applications_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "opportunity_applications" ADD CONSTRAINT "opportunity_applications_opportunity_id_opportunities_id_fk" FOREIGN KEY ("opportunity_id") REFERENCES "public"."opportunities"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "opportunity_applications" ADD CONSTRAINT "opportunity_applications_approved_by_users_id_fk" FOREIGN KEY ("approved_by") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "organization_documents" ADD CONSTRAINT "organization_documents_ngo_id_organizations_id_fk" FOREIGN KEY ("ngo_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "organization_members" ADD CONSTRAINT "organization_members_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "organization_members" ADD CONSTRAINT "organization_members_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "organizations" ADD CONSTRAINT "organizations_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "volunteers_feedback" ADD CONSTRAINT "volunteers_feedback_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "volunteers_feedback" ADD CONSTRAINT "volunteers_feedback_opportunity_id_opportunities_id_fk" FOREIGN KEY ("opportunity_id") REFERENCES "public"."opportunities"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "volunteers_feedback" ADD CONSTRAINT "volunteers_feedback_volunteer_id_users_id_fk" FOREIGN KEY ("volunteer_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "moderation_monitoring_type_idx" ON "moderation_monitoring" USING btree ("moderation_type");--> statement-breakpoint
CREATE INDEX "moderation_monitoring_status_idx" ON "moderation_monitoring" USING btree ("status");--> statement-breakpoint
CREATE INDEX "moderation_monitoring_priority_idx" ON "moderation_monitoring" USING btree ("priority");--> statement-breakpoint
CREATE INDEX "moderation_monitoring_reported_by_idx" ON "moderation_monitoring" USING btree ("reported_by");--> statement-breakpoint
CREATE INDEX "moderation_monitoring_assigned_to_idx" ON "moderation_monitoring" USING btree ("assigned_to");--> statement-breakpoint
CREATE INDEX "moderation_monitoring_reviewed_by_idx" ON "moderation_monitoring" USING btree ("reviewed_by");--> statement-breakpoint
CREATE INDEX "moderation_monitoring_created_at_idx" ON "moderation_monitoring" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "moderators_user_id_idx" ON "moderators" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "moderators_is_active_idx" ON "moderators" USING btree ("is_active");--> statement-breakpoint
CREATE INDEX "opportunities_ngo_id_idx" ON "opportunities" USING btree ("ngo_id");--> statement-breakpoint
CREATE INDEX "opportunities_user_created_by_idx" ON "opportunities" USING btree ("user_created_by");--> statement-breakpoint
CREATE INDEX "opportunities_status_idx" ON "opportunities" USING btree ("status");--> statement-breakpoint
CREATE INDEX "opportunities_mode_idx" ON "opportunities" USING btree ("opportunity_mode");--> statement-breakpoint
CREATE INDEX "opportunities_city_idx" ON "opportunities" USING btree ("city");--> statement-breakpoint
CREATE INDEX "opportunities_state_idx" ON "opportunities" USING btree ("state");--> statement-breakpoint
CREATE INDEX "opportunities_country_idx" ON "opportunities" USING btree ("country");--> statement-breakpoint
CREATE INDEX "opportunities_start_date_idx" ON "opportunities" USING btree ("start_date");--> statement-breakpoint
CREATE INDEX "opportunities_end_date_idx" ON "opportunities" USING btree ("end_date");--> statement-breakpoint
CREATE INDEX "opportunities_cause_categories_idx" ON "opportunities" USING btree ("cause_category_names");--> statement-breakpoint
CREATE INDEX "opportunities_required_skills_idx" ON "opportunities" USING btree ("required_skills");--> statement-breakpoint
CREATE INDEX "opportunities_feedback_user_id_idx" ON "opportunities_feedback" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "opportunities_feedback_opp_id_idx" ON "opportunities_feedback" USING btree ("opportunity_id");--> statement-breakpoint
CREATE INDEX "opportunities_feedback_rating_idx" ON "opportunities_feedback" USING btree ("rating");--> statement-breakpoint
CREATE INDEX "applications_opp_user_idx" ON "opportunity_applications" USING btree ("opportunity_id","user_id");--> statement-breakpoint
CREATE INDEX "applications_opp_id_idx" ON "opportunity_applications" USING btree ("opportunity_id");--> statement-breakpoint
CREATE INDEX "applications_user_id_idx" ON "opportunity_applications" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "applications_status_idx" ON "opportunity_applications" USING btree ("status");--> statement-breakpoint
CREATE INDEX "applications_approved_by_idx" ON "opportunity_applications" USING btree ("approved_by");--> statement-breakpoint
CREATE INDEX "org_documents_ngo_id_idx" ON "organization_documents" USING btree ("ngo_id");--> statement-breakpoint
CREATE INDEX "org_documents_type_idx" ON "organization_documents" USING btree ("document_type");--> statement-breakpoint
CREATE INDEX "org_members_org_user_idx" ON "organization_members" USING btree ("organization_id","user_id");--> statement-breakpoint
CREATE INDEX "org_members_user_id_idx" ON "organization_members" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "org_members_org_id_idx" ON "organization_members" USING btree ("organization_id");--> statement-breakpoint
CREATE INDEX "organizations_created_by_idx" ON "organizations" USING btree ("created_by");--> statement-breakpoint
CREATE INDEX "organizations_verification_status_idx" ON "organizations" USING btree ("verification_status");--> statement-breakpoint
CREATE INDEX "organizations_contact_email_idx" ON "organizations" USING btree ("contact_person_email");--> statement-breakpoint
CREATE INDEX "organizations_city_idx" ON "organizations" USING btree ("city");--> statement-breakpoint
CREATE INDEX "organizations_state_idx" ON "organizations" USING btree ("state");--> statement-breakpoint
CREATE INDEX "organizations_country_idx" ON "organizations" USING btree ("country");--> statement-breakpoint
CREATE INDEX "organizations_deleted_at_idx" ON "organizations" USING btree ("deleted_at");--> statement-breakpoint
CREATE INDEX "organizations_causes_idx" ON "organizations" USING btree ("causes");--> statement-breakpoint
CREATE INDEX "otp_tokens_email_code_idx" ON "otp_tokens" USING btree ("email","code");--> statement-breakpoint
CREATE INDEX "otp_tokens_expires_at_idx" ON "otp_tokens" USING btree ("expires_at");--> statement-breakpoint
CREATE INDEX "otp_tokens_expires_used_idx" ON "otp_tokens" USING btree ("expires_at","used");--> statement-breakpoint
CREATE INDEX "otp_tokens_created_used_idx" ON "otp_tokens" USING btree ("created_at","used");--> statement-breakpoint
CREATE INDEX "sessions_user_id_idx" ON "sessions" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "sessions_token_idx" ON "sessions" USING btree ("token");--> statement-breakpoint
CREATE INDEX "sessions_expires_at_idx" ON "sessions" USING btree ("expires_at");--> statement-breakpoint
CREATE INDEX "users_email_idx" ON "users" USING btree ("email");--> statement-breakpoint
CREATE INDEX "users_is_admin_idx" ON "users" USING btree ("is_admin");--> statement-breakpoint
CREATE INDEX "users_deleted_at_idx" ON "users" USING btree ("deleted_at");--> statement-breakpoint
CREATE INDEX "volunteers_feedback_opp_id_idx" ON "volunteers_feedback" USING btree ("opportunity_id");--> statement-breakpoint
CREATE INDEX "volunteers_feedback_user_id_idx" ON "volunteers_feedback" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "volunteers_feedback_volunteer_id_idx" ON "volunteers_feedback" USING btree ("volunteer_id");--> statement-breakpoint
CREATE INDEX "volunteers_feedback_rating_idx" ON "volunteers_feedback" USING btree ("rating");