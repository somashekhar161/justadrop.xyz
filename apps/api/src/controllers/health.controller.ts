import { HealthService } from '../services/health.service';

const healthService = new HealthService();

export class HealthController {
  async getHealth() {
    return await healthService.getHealth();
  }
}
