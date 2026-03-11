import { ValidationError, ForbiddenError } from '../utils/errors.js';

import { OrganizationRepository } from '@/repositories/organization.repository.js';
import { EmailService } from './email.service.js';
import { StorageService } from './storage.service.js';

export class OrganizationModerationService {
  constructor(
    private readonly emailService: EmailService,
    private readonly organizationRepository: OrganizationRepository,
    private readonly storageService: StorageService
  ) {}

  async listPendingNGOs(data: { page: number; limit: number }) {
    const { page, limit } = data;
    const { data: pendingOrgs, pagination } =
      await this.organizationRepository.findByVerificationStatus('pending', page, limit);

    const pendingOrgsWithSignedURL = await Promise.all(
      pendingOrgs.map(async (org) => {
        if (org.documents?.length) {
          const documents = await this.storageService.getSignedUrls(org.documents);
          return { ...org, documents };
        }
        return org;
      })
    );

    return { data: pendingOrgsWithSignedURL, pagination };
  }

  async sendClarificationEmailToContactPerson(data: { organizationId: string; content: string }) {
    const organization = await this.organizationRepository.findById(data.organizationId);

    if (!organization) {
      throw new ForbiddenError('organization does not exist');
    }

    if (!organization.contactPersonEmail || !organization.contactPersonEmail.includes('@')) {
      throw new ValidationError('Valid email is required');
    }

    await this.emailService.sendNGOClariyEmail(
      organization.contactPersonEmail,
      organization.contactPersonName,
      data.content
    );
  }
}
