import { OrganizationModerationService } from '@/services/organization-moderation.service';

export class OrganizationModerationController {
  constructor(private readonly organizationModerationService: OrganizationModerationService) {}

  async getPendingNGOs(data: { page: number; limit: number }) {
    return await this.organizationModerationService.listPendingNGOsWithSignedDocumentURL(data);
  }

  async sendClarifyEmail(data: { organizationId: string; content: string }) {
    await this.organizationModerationService.sendClarificationEmailToContactPerson(data);
    return { message: 'Clarification Email sent  successfully' };
  }
}
