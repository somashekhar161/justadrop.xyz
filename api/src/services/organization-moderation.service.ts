import { ValidationError, ForbiddenError } from '../utils/errors.js';

import { OrganizationRepository } from '@/repositories/organization.repository.js';
import { EmailService } from './email.service.js';

export class OrganizationModerationService {
  constructor(
    private readonly emailService: EmailService,
    private readonly organizationRepository: OrganizationRepository
  ) {}

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
