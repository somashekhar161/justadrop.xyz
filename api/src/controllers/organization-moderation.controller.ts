import { OrganizationModerationService } from '@/services/organization-moderation.service';

export class OrganizationModerationController {
  constructor(private readonly organizationModerationService: OrganizationModerationService) {}

  async sendClarifyEmail(data: { organizationId: string; content: string }) {
    await this.organizationModerationService.sendClarificationEmailToContactPerson(data);
    return { message: 'Clarification Email sent  successfully' };
  }
}
