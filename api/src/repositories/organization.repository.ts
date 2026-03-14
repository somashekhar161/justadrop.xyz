import { db } from '../db/index.js';
import {
  organizations,
  organizationMembers,
  organizationDocuments,
  documentTypeEnum,
  organizationStatusEnum,
} from '../db/schema.js';
import { eq, inArray, and, sql, ne, isNull, desc, isNotNull } from 'drizzle-orm';
import { createId } from '@paralleldrive/cuid2';

const ORG_OWNER_ROLE = 'owner' as const;

export type OrganizationStatus = (typeof organizationStatusEnum.enumValues)[number];

export interface Organization {
  id: string;
  createdBy: string;
  orgName: string;
  type: string | null;
  description: string | null;
  causes: string[];
  website: string | null;
  registrationNumber: string | null;
  contactPersonName: string;
  contactPersonEmail: string;
  contactPersonNumber: string | null;
  address: string | null;
  city: string | null;
  state: string | null;
  country: string | null;
  verificationStatus: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Document {
  id: string;
  createdAt: Date;
  updatedAt: Date;
  ngoId: string;
  documentType:
    | 'registration_certificate'
    | '80G_certificate'
    | '12A_certificate'
    | 'PAN'
    | 'proof_of_address';
  documentAssetUrl: string;
  format: string;
}

export interface AdminOrganizationListFilters {
  verificationStatus?: Array<'pending' | 'verified' | 'rejected' | 'suspended'>;
  type?: string;
  causes?: string[];
  state?: string;
  city?: string;
  isCsrEligible?: boolean;
  deletedAt?: boolean;
  page?: number;
  limit?: number;
}
export interface OrganizationWithDocument extends Organization {
  documents: Document[];
}

export class OrganizationRepository {
  async create(data: {
    createdBy: string;
    orgName: string;
    type?: string | null;
    description?: string;
    causes?: string[];
    website?: string;
    registrationNumber?: string;
    contactPersonName: string;
    contactPersonEmail: string;
    contactPersonNumber?: string;
    address?: string;
    city?: string;
    state?: string;
    country?: string;
    documents?: Array<{ documentType: string; documentAssetUrl: string; format: string }>;
  }): Promise<Organization> {
    const id = createId();
    await db.transaction(async (tx) => {
      await tx.insert(organizations).values({
        id,
        createdBy: data.createdBy,
        orgName: data.orgName,
        type: data.type ?? null,
        description: data.description ?? null,
        causes: data.causes ?? [],
        website: data.website ?? null,
        registrationNumber: data.registrationNumber ?? null,
        contactPersonName: data.contactPersonName,
        contactPersonEmail: data.contactPersonEmail,
        contactPersonNumber: data.contactPersonNumber ?? null,
        address: data.address ?? null,
        city: data.city ?? null,
        state: data.state ?? null,
        country: data.country ?? 'India',
      });

      // Add creator as owner
      await tx.insert(organizationMembers).values({
        id: createId(),
        organizationId: id,
        userId: data.createdBy,
        role: ORG_OWNER_ROLE,
      });

      // Add documents if provided
      if (data.documents?.length) {
        await tx.insert(organizationDocuments).values(
          data.documents.map((doc) => ({
            id: createId(),
            ngoId: id,
            documentType: doc.documentType as (typeof documentTypeEnum.enumValues)[number],
            documentAssetUrl: doc.documentAssetUrl,
            format: doc.format,
          }))
        );
      }
    });

    const org = await db.query.organizations.findFirst({
      where: eq(organizations.id, id),
    });

    if (!org) throw new Error('Failed to create organization');

    return {
      id: org.id,
      createdBy: org.createdBy,
      orgName: org.orgName,
      type: org.type ?? null,
      description: org.description,
      causes: org.causes,
      website: org.website,
      registrationNumber: org.registrationNumber,
      contactPersonName: org.contactPersonName,
      contactPersonEmail: org.contactPersonEmail,
      contactPersonNumber: org.contactPersonNumber,
      address: org.address,
      city: org.city,
      state: org.state,
      country: org.country,
      verificationStatus: org.verificationStatus,
      createdAt: org.createdAt,
      updatedAt: org.updatedAt,
    };
  }

  async findById(id: string): Promise<Organization | null> {
    const org = await db.query.organizations.findFirst({
      where: eq(organizations.id, id),
    });
    if (!org) return null;
    return {
      id: org.id,
      createdBy: org.createdBy,
      orgName: org.orgName,
      type: org.type ?? null,
      description: org.description,
      causes: org.causes,
      website: org.website,
      registrationNumber: org.registrationNumber,
      contactPersonName: org.contactPersonName,
      contactPersonEmail: org.contactPersonEmail,
      contactPersonNumber: org.contactPersonNumber,
      address: org.address,
      city: org.city,
      state: org.state,
      country: org.country,
      verificationStatus: org.verificationStatus,
      createdAt: org.createdAt,
      updatedAt: org.updatedAt,
    };
  }

  async findAllWithFilters(filters: AdminOrganizationListFilters): Promise<{
    data: OrganizationWithDocument[];
    pagination: { page: number; limit: number; total: number; totalPages: number };
  }> {
    const {
      verificationStatus,
      type,
      causes,
      state,
      city,
      isCsrEligible,
      deletedAt = false,
      page = 1,
      limit = 20,
    } = filters;

    const offset = (page - 1) * limit;

    const conditions: ReturnType<typeof and>[] = [];

    if (verificationStatus !== undefined && verificationStatus.length > 0) {
      conditions.push(inArray(organizations.verificationStatus, verificationStatus));
    }

    if (type !== undefined) {
      // filter by organization type
      conditions.push(eq(organizations.type, type));
    }

    if (causes?.length) {
      const causesChecks = causes.map(
        (c) => sql`(${organizations.causes} @> ${JSON.stringify([c])}::jsonb)`
      );
      conditions.push(sql`(${sql.join(causesChecks, sql` OR `)})`);
    }

    if (state !== undefined) {
      conditions.push(eq(organizations.state, state));
    }

    if (city !== undefined) {
      conditions.push(eq(organizations.city, city));
    }

    if (isCsrEligible !== undefined) {
      conditions.push(eq(organizations.isCsrEligible, isCsrEligible));
    }

    if (deletedAt !== undefined) {
      if (deletedAt) {
        conditions.push(isNotNull(organizations.deletedAt));
      } else {
        conditions.push(isNull(organizations.deletedAt));
      }
    }

    const whereClause = conditions.length > 0 ? and(...conditions) : sql`true`;
    const cappedLimit = Math.min(limit, 100);

    const [data, totalResult] = await Promise.all([
      db.query.organizations.findMany({
        where: whereClause,
        with: { documents: true },
        limit: cappedLimit,
        offset,
        orderBy: desc(organizations.createdAt),
      }),
      db
        .select({ total: sql`count(*)`.mapWith(Number) })
        .from(organizations)
        .where(whereClause),
    ]);

    const total = totalResult[0].total;

    return {
      data: data.map((organization) => ({
        id: organization.id,
        createdBy: organization.createdBy,
        orgName: organization.orgName,
        type: organization.type ?? null,
        description: organization.description,
        causes: organization.causes,
        website: organization.website,
        registrationNumber: organization.registrationNumber,
        contactPersonName: organization.contactPersonName,
        contactPersonEmail: organization.contactPersonEmail,
        contactPersonNumber: organization.contactPersonNumber,
        address: organization.address,
        city: organization.city,
        state: organization.state,
        country: organization.country,
        verificationStatus: organization.verificationStatus,
        createdAt: organization.createdAt,
        updatedAt: organization.updatedAt,
        documents: organization.documents,
      })),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findByUserId(userId: string): Promise<Organization[]> {
    const createdByOrgs = await db
      .select({ id: organizations.id })
      .from(organizations)
      .where(eq(organizations.createdBy, userId));
    const memberOrgs = await db
      .select({ organizationId: organizationMembers.organizationId })
      .from(organizationMembers)
      .where(eq(organizationMembers.userId, userId));
    const orgIds = [
      ...new Set([...createdByOrgs.map((o) => o.id), ...memberOrgs.map((m) => m.organizationId)]),
    ];
    if (orgIds.length === 0) return [];
    const list = await db.query.organizations.findMany({
      where: inArray(organizations.id, orgIds),
    });
    return list.map((org) => ({
      id: org.id,
      createdBy: org.createdBy,
      orgName: org.orgName,
      type: org.type ?? null,
      description: org.description,
      causes: org.causes,
      website: org.website,
      registrationNumber: org.registrationNumber,
      contactPersonName: org.contactPersonName,
      contactPersonEmail: org.contactPersonEmail,
      contactPersonNumber: org.contactPersonNumber,
      address: org.address,
      city: org.city,
      state: org.state,
      country: org.country,
      verificationStatus: org.verificationStatus,
      createdAt: org.createdAt,
      updatedAt: org.updatedAt,
    }));
  }

  async update(
    id: string,
    data: {
      orgName?: string;
      type?: string | null;
      description?: string | null;
      causes?: string[];
      website?: string | null;
      registrationNumber?: string | null;
      contactPersonName?: string;
      contactPersonEmail?: string;
      contactPersonNumber?: string | null;
      address?: string | null;
      city?: string | null;
      state?: string | null;
      country?: string | null;
    }
  ): Promise<Organization | null> {
    const [updated] = await db
      .update(organizations)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(eq(organizations.id, id))
      .returning();
    if (!updated) return null;
    return {
      id: updated.id,
      createdBy: updated.createdBy,
      orgName: updated.orgName,
      type: updated.type ?? null,
      description: updated.description,
      causes: updated.causes,
      website: updated.website,
      registrationNumber: updated.registrationNumber,
      contactPersonName: updated.contactPersonName,
      contactPersonEmail: updated.contactPersonEmail,
      contactPersonNumber: updated.contactPersonNumber,
      address: updated.address,
      city: updated.city,
      state: updated.state,
      country: updated.country,
      verificationStatus: updated.verificationStatus,
      createdAt: updated.createdAt,
      updatedAt: updated.updatedAt,
    };
  }

  async hasManageAccess(ngoId: string, userId: string): Promise<boolean> {
    const org = await db.query.organizations.findFirst({
      where: eq(organizations.id, ngoId),
    });
    if (!org) return false;
    if (org.createdBy === userId) return true;
    const members = await db
      .select()
      .from(organizationMembers)
      .where(
        and(eq(organizationMembers.organizationId, ngoId), eq(organizationMembers.userId, userId))
      );
    const member = members[0];
    return member != null && (member.role === 'owner' || member.role === 'admin');
  }

  async findByCreatedBy(userId: string): Promise<Organization[]> {
    const list = await db.query.organizations.findMany({
      where: eq(organizations.createdBy, userId),
    });
    return list.map((org) => ({
      id: org.id,
      createdBy: org.createdBy,
      orgName: org.orgName,
      type: org.type ?? null,
      description: org.description,
      causes: org.causes,
      website: org.website,
      registrationNumber: org.registrationNumber,
      contactPersonName: org.contactPersonName,
      contactPersonEmail: org.contactPersonEmail,
      contactPersonNumber: org.contactPersonNumber,
      address: org.address,
      city: org.city,
      state: org.state,
      country: org.country,
      verificationStatus: org.verificationStatus,
      createdAt: org.createdAt,
      updatedAt: org.updatedAt,
    }));
  }

  async UpdateVerificationStatus(
    organizationId: string,
    organizationStatus: OrganizationStatus
  ): Promise<Organization[]> {
    const data = await db
      .update(organizations)
      .set({ verificationStatus: organizationStatus })
      .where(
        and(
          ne(organizations.verificationStatus, organizationStatus),
          eq(organizations.id, organizationId)
        )
      )
      .returning();

    return [
      ...data.map((organizations) => ({
        id: organizations.id,
        createdBy: organizations.createdBy,
        orgName: organizations.orgName,
        type: organizations.type ?? null,
        description: organizations.description,
        causes: organizations.causes,
        website: organizations.website,
        registrationNumber: organizations.registrationNumber,
        contactPersonName: organizations.contactPersonName,
        contactPersonEmail: organizations.contactPersonEmail,
        contactPersonNumber: organizations.contactPersonNumber,
        address: organizations.address,
        city: organizations.city,
        state: organizations.state,
        country: organizations.country,
        verificationStatus: organizations.verificationStatus,
        createdAt: organizations.createdAt,
        updatedAt: organizations.updatedAt,
      })),
    ];
  }
}
