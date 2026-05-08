# OpenShift Airgap Architect - Contribution Guidelines

**Upstream Repository:** https://github.com/bstrauss84/openshift-airgap-architect/  
**Maintainer:** @bstrauss84  
**License:** Apache 2.0  
**Purpose:** Document enhancements needed for operator integration

## Overview

This document outlines the enhancements we plan to contribute to the upstream OpenShift Airgap Architect project to enable integration with the Disconnected Platform Operator.

**Guiding Principle:** All enhancements must maintain backward compatibility with standalone airgap-architect usage.

---

## Enhancement Strategy

### Fork vs. Upstream Contributions

**Preferred Approach:** Contribute to upstream

**Reasons:**
- ✅ Benefits entire community
- ✅ Shared maintenance burden
- ✅ Avoid fork drift
- ✅ Upstream features available to all users

**When to Fork:**
- ⚠️ Only if upstream cannot accept operator-specific features
- ⚠️ Must maintain sync with upstream main branch
- ⚠️ Plan to eventually merge back to upstream

**Decision:** Start with upstream contributions, fork only if necessary

---

## Required Enhancements

### 1. Kubernetes API Integration

**Priority:** HIGH  
**Status:** Proposed  
**Complexity:** Medium

#### Current State
Airgap-architect is a standalone Node.js application with no Kubernetes awareness.

#### Proposed Enhancement
Add **optional** Kubernetes API client integration.

#### Technical Design

**New Files:**
```
server/
├── kubernetes/
│   ├── client.js         # Kubernetes API client wrapper
│   ├── detector.js       # Environment detection
│   ├── pipeline.js       # Pipeline trigger integration
│   └── configmap.js      # ConfigMap storage
```

**Environment Detection:**
```javascript
// server/kubernetes/detector.js
const detectEnvironment = async () => {
  // Check if running in Kubernetes
  if (process.env.KUBERNETES_SERVICE_HOST) {
    const mode = await detectClusterMode();
    return { inCluster: true, mode };
  }
  return { inCluster: false, mode: 'standalone' };
};

const detectClusterMode = async () => {
  // Check for DisconnectedPlatform CR
  try {
    const dp = await k8sApi.getClusterCustomObject(
      'disconnected.openshift.io',
      'v1alpha1',
      'disconnectedplatforms',
      'disconnected-platform'
    );
    return dp.body.spec.mode; // 'connected' or 'airgapped'
  } catch (error) {
    return 'unknown';
  }
};
```

**Configuration:**
```javascript
// config/kubernetes.js
module.exports = {
  enabled: process.env.K8S_INTEGRATION_ENABLED === 'true',
  namespace: process.env.POD_NAMESPACE || 'disconnected-platform',
  features: {
    pipelineTrigger: process.env.K8S_PIPELINE_TRIGGER === 'true',
    configMapStorage: process.env.K8S_CONFIGMAP_STORAGE === 'true',
    gitOpsCommit: process.env.K8S_GITOPS_COMMIT === 'true'
  }
};
```

**Backward Compatibility:**
- Default: Kubernetes integration disabled
- Standalone mode: Works exactly as before
- Operator mode: Enable via environment variables

#### API Endpoints

**New Endpoints:**
```javascript
// POST /api/kubernetes/pipeline/trigger
// Trigger Tekton PipelineRun from UI

app.post('/api/kubernetes/pipeline/trigger', async (req, res) => {
  if (!k8sConfig.enabled || !k8sConfig.features.pipelineTrigger) {
    return res.status(501).json({ error: 'Kubernetes integration not enabled' });
  }

  const { imageSetConfig, triggerType } = req.body;
  
  try {
    const pipelineRun = await createPipelineRun(imageSetConfig, triggerType);
    res.json({ 
      success: true, 
      pipelineRun: pipelineRun.metadata.name,
      namespace: pipelineRun.metadata.namespace
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/kubernetes/pipeline/:name
// Get PipelineRun status for UI display

app.get('/api/kubernetes/pipeline/:name', async (req, res) => {
  // Return PipelineRun status
});
```

**UI Integration:**
```jsx
// app/src/components/ConfigurationWizard.jsx

const ConfigurationWizard = () => {
  const [k8sMode, setK8sMode] = useState(null);

  useEffect(() => {
    // Detect if running in Kubernetes
    fetch('/api/kubernetes/status')
      .then(res => res.json())
      .then(data => setK8sMode(data))
      .catch(() => setK8sMode({ enabled: false }));
  }, []);

  const handleSave = async (config) => {
    if (k8sMode?.enabled && k8sMode?.features?.pipelineTrigger) {
      // Show "Save and Run Pipeline" button
      return (
        <div>
          <button onClick={downloadConfig}>Download Config</button>
          <button onClick={triggerPipeline}>Save and Run Pipeline</button>
        </div>
      );
    } else {
      // Standard standalone behavior
      return <button onClick={downloadConfig}>Download Config</button>;
    }
  };
};
```

#### Contribution Plan

1. **Phase 1: Detection** (Week 1)
   - Add Kubernetes environment detection
   - No functional changes, just detection
   - PR: "Add Kubernetes environment detection"

2. **Phase 2: Optional API Client** (Week 2)
   - Add optional K8s API client
   - Disabled by default
   - PR: "Add optional Kubernetes API client integration"

3. **Phase 3: Pipeline Trigger** (Week 3)
   - Implement PipelineRun creation
   - UI changes for "Save and Run"
   - PR: "Add Tekton pipeline trigger capability"

4. **Phase 4: Status Monitoring** (Week 4)
   - PipelineRun status display in UI
   - Real-time updates
   - PR: "Add pipeline execution monitoring UI"

---

### 2. Mode-Aware UI

**Priority:** HIGH  
**Status:** Proposed  
**Complexity:** Medium

#### Current State
Single UI workflow for all scenarios.

#### Proposed Enhancement
Adapt UI based on detected environment mode.

#### Technical Design

**Mode Detection:**
```javascript
// app/src/contexts/EnvironmentContext.jsx

export const EnvironmentProvider = ({ children }) => {
  const [environment, setEnvironment] = useState({
    mode: 'standalone', // 'standalone' | 'connected' | 'airgapped'
    features: {
      pipelineTrigger: false,
      importWizard: false,
      bootstrapWizard: false
    }
  });

  useEffect(() => {
    fetch('/api/environment')
      .then(res => res.json())
      .then(data => setEnvironment(data))
      .catch(() => {
        // Fallback to standalone
        setEnvironment({ 
          mode: 'standalone', 
          features: {} 
        });
      });
  }, []);

  return (
    <EnvironmentContext.Provider value={environment}>
      {children}
    </EnvironmentContext.Provider>
  );
};
```

**Conditional UI:**
```jsx
// app/src/App.jsx

import { useEnvironment } from './contexts/EnvironmentContext';

const App = () => {
  const { mode, features } = useEnvironment();

  return (
    <Router>
      <Routes>
        {/* Available in all modes */}
        <Route path="/config" element={<ConfigWizard />} />
        
        {/* Connected mode only */}
        {(mode === 'connected' || mode === 'standalone') && (
          <Route path="/collections" element={<CollectionsView />} />
        )}
        
        {/* Airgapped mode only */}
        {mode === 'airgapped' && (
          <>
            <Route path="/import" element={<ImportWizard />} />
            {features.bootstrapWizard && (
              <Route path="/bootstrap" element={<BootstrapWizard />} />
            )}
          </>
        )}
      </Routes>
    </Router>
  );
};
```

**Navigation Adaptation:**
```jsx
// app/src/components/Navigation.jsx

const Navigation = () => {
  const { mode } = useEnvironment();

  return (
    <nav>
      <NavItem to="/config">Configuration</NavItem>
      
      {mode === 'connected' && (
        <>
          <NavItem to="/collections">Collections</NavItem>
          <NavItem to="/mirror">Run Mirror</NavItem>
        </>
      )}
      
      {mode === 'airgapped' && (
        <>
          <NavItem to="/import">Import</NavItem>
          <NavItem to="/bootstrap">Bootstrap Clusters</NavItem>
        </>
      )}
    </nav>
  );
};
```

#### Contribution Plan

1. **PR 1:** Add environment context (no UI changes yet)
2. **PR 2:** Adapt navigation based on mode
3. **PR 3:** Add connected-mode specific features
4. **PR 4:** Add airgapped-mode specific features

---

### 3. Import Automation UI

**Priority:** MEDIUM  
**Status:** Proposed  
**Complexity:** High

#### Current State
Airgap-architect focuses on config generation and oc-mirror execution.

#### Proposed Enhancement
Add wizard for importing archives in airgapped environments.

#### Technical Design

**New Component:**
```jsx
// app/src/components/ImportWizard.jsx

const ImportWizard = () => {
  const [step, setStep] = useState('validate');
  const [archivePath, setArchivePath] = useState('');
  const [checksumStatus, setChecksumStatus] = useState(null);

  const steps = [
    { id: 'validate', label: 'Validate Archive' },
    { id: 'configure', label: 'Configure Import' },
    { id: 'execute', label: 'Execute Import' },
    { id: 'verify', label: 'Verify Import' }
  ];

  return (
    <WizardLayout steps={steps} currentStep={step}>
      {step === 'validate' && (
        <ValidateArchive 
          archivePath={archivePath}
          onValidated={(path, checksums) => {
            setArchivePath(path);
            setChecksumStatus(checksums);
            setStep('configure');
          }}
        />
      )}
      
      {step === 'configure' && (
        <ConfigureImport
          archivePath={archivePath}
          onConfigured={() => setStep('execute')}
        />
      )}
      
      {step === 'execute' && (
        <ExecuteImport
          archivePath={archivePath}
          onCompleted={() => setStep('verify')}
        />
      )}
      
      {step === 'verify' && (
        <VerifyImport archivePath={archivePath} />
      )}
    </WizardLayout>
  );
};
```

**Backend Endpoint:**
```javascript
// POST /api/import/start
app.post('/api/import/start', async (req, res) => {
  const { archivePath, registryUrl, credentials } = req.body;
  
  // Execute import (similar to bootstrap-import.sh)
  const importJob = await startImport({
    archivePath,
    registryUrl,
    credentials
  });
  
  res.json({ jobId: importJob.id });
});

// GET /api/import/:jobId/status
app.get('/api/import/:jobId/status', async (req, res) => {
  const status = await getImportStatus(req.params.jobId);
  res.json(status);
});
```

#### Contribution Plan

This is operator-specific and may need to be in a fork or separate package:

**Option A:** Contribute to upstream as "optional feature"
- PR with feature flag
- Disabled by default
- Enables when operator sets environment variable

**Option B:** Separate npm package
- `@disconnected-platform/airgap-architect-import`
- Pluggable architecture
- Airgap-architect supports plugins

**Decision:** Propose plugin architecture to upstream first

---

### 4. Bootstrap Wizard UI

**Priority:** MEDIUM  
**Status:** Proposed  
**Complexity:** Very High

#### Current State
No cluster bootstrap UI.

#### Proposed Enhancement
UI for creating new OpenShift clusters from imported artifacts.

#### Technical Design

This is **highly operator-specific** and likely belongs in operator repository as a console plugin, NOT in upstream airgap-architect.

**Recommendation:** 
- Keep airgap-architect focused on config generation and mirror operations
- Build bootstrap UI as **OpenShift Console Plugin** in operator repository
- Console plugin can embed/reuse airgap-architect components

**If contributed to upstream:**
- Make it a completely optional plugin
- Use OpenShift Console SDK
- Package separately

---

## Contribution Process

### 1. Before Contributing

- [ ] **Discuss with upstream maintainer** (@bstrauss84)
- [ ] Open GitHub issue describing enhancement
- [ ] Get feedback on approach
- [ ] Agree on design before coding

### 2. Development Guidelines

**Code Style:**
- Follow existing ESLint configuration
- Match current code formatting
- Add JSDoc comments for new APIs

**Testing:**
- Add unit tests for new backend functions
- Add React component tests
- Maintain test coverage above 80%

**Documentation:**
- Update README.md with new features
- Add API documentation
- Include examples

**Backward Compatibility:**
- All new features must be optional
- Default behavior unchanged
- Feature flags for operator-specific features

### 3. Pull Request Process

```markdown
## PR Template for Airgap-Architect Enhancements

### Description
Brief description of the enhancement

### Motivation
Why this enhancement is valuable to the community

### Operator Integration
- [ ] Optional feature (disabled by default)
- [ ] Works in standalone mode
- [ ] Enables operator integration when configured

### Testing
- [ ] Unit tests added/updated
- [ ] Manual testing in standalone mode
- [ ] Manual testing in Kubernetes
- [ ] Documentation updated

### Screenshots (if UI changes)
[Screenshots here]

### Related Issues
Fixes #XXX

### Checklist
- [ ] Backward compatible
- [ ] Feature flagged
- [ ] Tests passing
- [ ] Documentation updated
- [ ] ESLint passing
```

### 4. Review and Merge

- Expect feedback and iteration
- Be responsive to maintainer comments
- May need to split large PRs
- Respect maintainer's decision on features

---

## Feature Compatibility Matrix

| Feature | Standalone | Connected | Airgapped | Requires Operator |
|---------|-----------|-----------|-----------|-------------------|
| Config Generation | ✅ | ✅ | ✅ | ❌ |
| oc-mirror Execution | ✅ | ✅ | ✅ | ❌ |
| Operator Discovery | ✅ | ✅ | ✅ | ❌ |
| Pipeline Trigger | ❌ | ✅ | ❌ | ✅ |
| GitOps Commit | ❌ | ✅ | ❌ | ✅ |
| Import Wizard | ❌ | ❌ | ✅ | ✅ |
| Bootstrap UI | ❌ | ❌ | ✅ | ✅ |
| Mode Detection | ✅ | ✅ | ✅ | ✅ |

**Legend:**
- ✅ Available
- ❌ Not Available / Not Applicable

---

## Fork Strategy (If Needed)

### When to Fork

Only fork if:
1. Upstream cannot accept operator-specific features
2. Changes are too invasive for upstream
3. Development pace needs to be faster than upstream

### Fork Management

```bash
# Add upstream remote
git remote add upstream https://github.com/bstrauss84/openshift-airgap-architect.git

# Sync with upstream regularly
git fetch upstream
git merge upstream/main

# Maintain feature branches
git checkout -b operator/kubernetes-integration
git checkout -b operator/import-wizard
```

### Fork Repository Name

If forking: `openshift-airgap-architect-operator`

### Contribution Back to Upstream

Even with a fork:
1. Extract generic features
2. Propose to upstream
3. Reduce fork diff over time
4. Goal: Eventually merge fork back

---

## Implementation Timeline

### Short Term (Weeks 1-4)
- **Week 1:** Contact @bstrauss84, discuss enhancements
- **Week 2:** Open GitHub issues for each enhancement
- **Week 3:** Prototype Kubernetes detection (PR #1)
- **Week 4:** Implement optional K8s API client (PR #2)

### Medium Term (Weeks 5-8)
- **Week 5:** Add pipeline trigger capability (PR #3)
- **Week 6:** Implement mode-aware UI (PR #4)
- **Week 7:** Add pipeline status monitoring (PR #5)
- **Week 8:** Testing and documentation

### Long Term (Weeks 9-12)
- **Week 9:** Propose plugin architecture for import/bootstrap
- **Week 10:** Implement plugins if accepted
- **Week 11:** Integration testing with operator
- **Week 12:** Production readiness

---

## Communication Channels

### GitHub
- **Issues:** Feature proposals and bug reports
- **Discussions:** Design discussions
- **Pull Requests:** Code contributions

### Direct Communication
- **Email:** Reach out to @bstrauss84
- **Community Slack:** (if available)

### Documentation
- **Enhancement Tracking:** This document
- **Implementation Notes:** In each PR description
- **Decision Log:** In GitHub issue comments

---

## Testing Strategy

### Unit Tests
```javascript
// server/kubernetes/detector.test.js
describe('Kubernetes Detection', () => {
  it('should detect standalone mode when not in cluster', async () => {
    delete process.env.KUBERNETES_SERVICE_HOST;
    const env = await detectEnvironment();
    expect(env.mode).toBe('standalone');
  });

  it('should detect connected mode when in cluster', async () => {
    process.env.KUBERNETES_SERVICE_HOST = 'kubernetes.default';
    // Mock DisconnectedPlatform CR
    const env = await detectEnvironment();
    expect(env.mode).toBe('connected');
  });
});
```

### Integration Tests
```javascript
// test/integration/kubernetes.test.js
describe('Kubernetes Integration', () => {
  it('should trigger pipeline when in connected mode', async () => {
    const response = await request(app)
      .post('/api/kubernetes/pipeline/trigger')
      .send({
        imageSetConfig: '...',
        triggerType: 'manual'
      });
    
    expect(response.status).toBe(200);
    expect(response.body.pipelineRun).toBeDefined();
  });
});
```

### E2E Tests
```javascript
// e2e/operator-integration.spec.js
describe('Operator Integration E2E', () => {
  it('should complete full workflow in operator mode', async () => {
    // 1. Load app in connected mode
    await page.goto('http://airgap-architect.apps.example.com');
    
    // 2. Verify mode detected
    const mode = await page.evaluate(() => window.__ENV__.mode);
    expect(mode).toBe('connected');
    
    // 3. Generate config
    await page.click('#generate-config');
    
    // 4. Trigger pipeline
    await page.click('#run-pipeline');
    
    // 5. Verify pipeline created
    const pipelineRun = await getPipelineRun();
    expect(pipelineRun).toBeDefined();
  });
});
```

---

## Success Criteria

### For Upstream Contributions
- ✅ All PRs reviewed and merged to upstream
- ✅ Features available in official releases
- ✅ Backward compatibility maintained
- ✅ Community adoption of operator-integration features

### For Fork (if needed)
- ✅ Fork maintained with < 100 commits ahead of upstream
- ✅ Regular sync with upstream (weekly)
- ✅ Generic features contributed back
- ✅ Clear documentation of fork differences

---

## Rollback Plan

If upstream rejects operator-specific features:

1. **Maintain fork** for operator use
2. **Console plugin** for UI features
3. **Sidecar container** for Kubernetes integration
4. **Continue contributing** non-operator features

---

## Conclusion

Our contribution strategy prioritizes:
1. **Community benefit** - upstream contributions first
2. **Backward compatibility** - standalone mode always works
3. **Optional features** - operator integration is opt-in
4. **Respect upstream** - maintainer's decisions are final

**Next Steps:**
1. Contact @bstrauss84 with enhancement proposals
2. Start with least invasive changes (detection)
3. Build trust with quality contributions
4. Gradually add operator-specific features

---

**Status:** 📋 Ready for Upstream Engagement  
**Owner:** Platform Team  
**Maintainer Contact:** @bstrauss84  
**Repository:** https://github.com/bstrauss84/openshift-airgap-architect/
