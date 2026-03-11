import { Elysia, t } from 'elysia';
import { cookie } from '@elysiajs/cookie';
import { container } from '../container';

import {
  moderatorMiddleware,
  verifyXAuthHeaderMiddleware,
} from '@/middleware/moderator.middleware';

const organizationRepository = container.getRepositories().organization;
const organizationModerationController = container.getControllers().organizationModeration;

const action = {
  verified: 'verified',
  rejected: 'rejected',
  suspended: 'suspended',
} as const;

export const organizationsModerationRouter = new Elysia({
  prefix: '/moderation/ngos',
  tags: ['moderation-ngos'],
})
  .use(cookie())
  .use(verifyXAuthHeaderMiddleware)
  .use(moderatorMiddleware)
  .get(
    '/pending',
    async (ctx: any) => {
      const { page, limit } = ctx.query;
      const pendingOrgs = await organizationModerationController.getPendingNGOs({ page, limit });
      return pendingOrgs;
    },
    {
      headers: t.Object({
        'x-auth-id': t.String(),
      }),
      query: t.Object({
        page: t.Number({ minimum: 1 }),
        limit: t.Number({ minimum: 1, maximum: 100 }),
      }),
    }
  )
  .patch(
    '/:organizationId/action',
    async (ctx) => {
      const { organizationId, action } = ctx.body;
      const org = await organizationRepository.UpdateVerificationStatus(organizationId, action);
      return org;
    },
    {
      headers: t.Object({
        'x-auth-id': t.String(),
      }),
      params: t.Object({
        organizationId: t.String({ minLength: 24, maxLength: 24, pattern: '^[a-z0-9]+$' }),
      }),
      body: t.Object({
        organizationId: t.String({ minLength: 24, maxLength: 24, pattern: '^[a-z0-9]+$' }),
        action: t.Enum(action),
      }),
    }
  )
  .post(
    '/:organizationId/clarify',
    async (ctx) => {
      const { content } = ctx.body;
      const { organizationId } = ctx.params;
      return await organizationModerationController.sendClarifyEmail({
        organizationId,
        content,
      });
    },
    {
      headers: t.Object({
        'x-auth-id': t.String(),
      }),
      params: t.Object({
        organizationId: t.String({ minLength: 24, maxLength: 24, pattern: '^[a-z0-9]+$' }),
      }),
      body: t.Object({
        content: t.String({ minLength: 5, maxLength: 1000 }),
      }),
    }
  );
