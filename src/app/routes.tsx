import { createBrowserRouter } from 'react-router';
import { MobileFrame } from './components/MobileFrame';
import { Welcome } from './screens/Welcome';
import { Demographics } from './screens/Demographics';
import { Medication } from './screens/Medication';
import { Baselines } from './screens/Baselines';
import { Complete } from './screens/Complete';
import { Dashboard } from './screens/Dashboard';
import { LogDose } from './screens/LogDose';
import { LogSideEffect } from './screens/LogSideEffect';
import { LogCost } from './screens/LogCost';
import { SwitchMedication } from './screens/SwitchMedication';
import { Comparison } from './screens/Comparison';
import { Adherence } from './screens/Adherence';
import { Insights } from './screens/Insights';
import { Profile } from './screens/Profile';
import { Notifications } from './screens/Notifications';

export const router = createBrowserRouter([
  {
    path: '/',
    Component: MobileFrame,
    children: [
      { index: true, Component: Welcome },
      { path: 'demographics', Component: Demographics },
      { path: 'medication', Component: Medication },
      { path: 'baselines', Component: Baselines },
      { path: 'complete', Component: Complete },
      { path: 'dashboard', Component: Dashboard },
      { path: 'log-dose', Component: LogDose },
      { path: 'log-side-effect', Component: LogSideEffect },
      { path: 'log-cost', Component: LogCost },
      { path: 'switch-medication', Component: SwitchMedication },
      { path: 'comparison', Component: Comparison },
      { path: 'adherence', Component: Adherence },
      { path: 'insights', Component: Insights },
      { path: 'profile', Component: Profile },
      { path: 'notifications', Component: Notifications },
    ],
  },
]);