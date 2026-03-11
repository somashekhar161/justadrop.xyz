import { relations } from 'drizzle-orm';
import { organizationDocuments, organizations } from './schema';

// relations.ts
export const organizationsRelations = relations(organizations, ({ many }) => ({
  documents: many(organizationDocuments),
}));

export const organizationDocumentsRelations = relations(organizationDocuments, ({ one }) => ({
  organization: one(organizations, {
    fields: [organizationDocuments.ngoId],
    references: [organizations.id],
  }),
}));
