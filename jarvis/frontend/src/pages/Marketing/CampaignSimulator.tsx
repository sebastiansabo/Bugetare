import { useMemo, useState, useCallback } from 'react'
import { useQuery } from '@tanstack/react-query'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Label } from '@/components/ui/label'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from '@/components/ui/tooltip'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { Checkbox } from '@/components/ui/checkbox'
import { Skeleton } from '@/components/ui/skeleton'
import { Badge } from '@/components/ui/badge'
import { cn } from '@/lib/utils'
import {
  Calculator, RotateCcw, Wand2, Plus, Users,
  Target, DollarSign, Car, TrendingUp, ChevronDown, ChevronRight, Info,
} from 'lucide-react'
import { marketingApi } from '@/api/marketing'
import type { SimBenchmark, SimChannelResult, SimStageTotal, SimTotals } from '@/types/marketing'

// ── Constants ──

const STAGES = ['awareness', 'consideration', 'conversion'] as const
type FunnelStage = typeof STAGES[number]

const STAGE_CONFIG: Record<FunnelStage, { label: string; color: string; bg: string; headerBg: string; textColor: string }> = {
  awareness:     { label: 'Awareness',     color: 'text-blue-600 dark:text-blue-400',   bg: 'bg-blue-50 dark:bg-blue-950/40',   headerBg: 'bg-blue-600',   textColor: 'text-white' },
  consideration: { label: 'Consideration', color: 'text-amber-600 dark:text-amber-400', bg: 'bg-amber-50 dark:bg-amber-950/40', headerBg: 'bg-amber-600',  textColor: 'text-white' },
  conversion:    { label: 'Conversion',    color: 'text-green-600 dark:text-green-400', bg: 'bg-green-50 dark:bg-green-950/40', headerBg: 'bg-green-600',  textColor: 'text-white' },
}

// Default active channels matching exercitiu.xlsx Modul 4
const DEFAULT_ACTIVE: Record<FunnelStage, Set<string>> = {
  awareness: new Set(['meta_traffic_aw', 'meta_reach', 'meta_video_views', 'youtube_skippable_aw', 'google_display']),
  consideration: new Set(['meta_engagement', 'special_activation']),
  conversion: new Set(['google_pmax_conv', 'meta_conversion']),
}

// Funnel synergy multipliers from exercitiu.xlsx hidden formulas
const AWARENESS_THRESHOLD = 0.42   // >42% of budget on awareness → 1.7x
const AWARENESS_MULTIPLIER = 1.7
const CONSIDERATION_THRESHOLD = 0.14 // >14% of budget on consideration → 1.5x
const CONSIDERATION_MULTIPLIER = 1.5

// Auto-distribute pattern from Toyota Masterclass
const AUTO_DISTRIBUTE = {
  months: [0.40, 0.35, 0.25],
  stages: [
    { awareness: 0.80, consideration: 0.10, conversion: 0.10 },
    { awareness: 0.50, consideration: 0.25, conversion: 0.25 },
    { awareness: 0.20, consideration: 0.30, conversion: 0.50 },
  ],
}

// ── Helpers ──

function fmtNum(n: number, decimals = 0): string {
  return n.toLocaleString('ro-RO', { minimumFractionDigits: decimals, maximumFractionDigits: decimals })
}

function fmtEur(n: number): string {
  return `€${fmtNum(n, 2)}`
}

function fmtPct(n: number): string {
  return `${(n * 100).toFixed(2)}%`
}

// ── Component ──

export default function CampaignSimulator() {
  // Inputs
  const [audienceSize, setAudienceSize] = useState(300000)
  const [totalBudget, setTotalBudget] = useState(10000)
  const [leadToSaleRate, setLeadToSaleRate] = useState(5) // percentage display
  const [allocations, setAllocations] = useState<Record<string, number>>({})
  const [activeChannels, setActiveChannels] = useState<Record<string, boolean>>(() => {
    const init: Record<string, boolean> = {}
    for (const [, keys] of Object.entries(DEFAULT_ACTIVE)) {
      for (const k of keys) init[k] = true
    }
    return init
  })
  const [collapsedStages, setCollapsedStages] = useState<Record<string, boolean>>({})

  // Fetch benchmarks
  const { data: benchmarkData, isLoading } = useQuery({
    queryKey: ['sim-benchmarks'],
    queryFn: () => marketingApi.getSimBenchmarks(),
    staleTime: 5 * 60_000,
  })
  const benchmarks = benchmarkData?.benchmarks ?? []

  // Group benchmarks by stage → channels (unique keys)
  const channelsByStage = useMemo(() => {
    const map: Record<FunnelStage, { key: string; label: string }[]> = {
      awareness: [], consideration: [], conversion: [],
    }
    const seen = new Set<string>()
    for (const b of benchmarks) {
      if (!seen.has(b.channel_key)) {
        seen.add(b.channel_key)
        const s = b.funnel_stage as FunnelStage
        if (map[s]) map[s].push({ key: b.channel_key, label: b.channel_label })
      }
    }
    return map
  }, [benchmarks])

  // Benchmark lookup map
  const benchmarkMap = useMemo(() => {
    const m = new Map<string, SimBenchmark>()
    for (const b of benchmarks) m.set(`${b.channel_key}-${b.month_index}`, b)
    return m
  }, [benchmarks])

  // ── Calculation engine ──
  const outputs = useMemo(() => {
    const perChannel: SimChannelResult[] = []
    const byStage: Record<string, SimStageTotal> = {}
    const byMonth: Record<number, SimStageTotal> = { 1: { budget: 0, clicks: 0, leads: 0 }, 2: { budget: 0, clicks: 0, leads: 0 }, 3: { budget: 0, clicks: 0, leads: 0 } }

    for (const stage of STAGES) {
      byStage[stage] = { budget: 0, clicks: 0, leads: 0 }
    }

    for (const stage of STAGES) {
      const channels = channelsByStage[stage] ?? []
      for (const ch of channels) {
        if (!activeChannels[ch.key]) continue
        for (const month of [1, 2, 3]) {
          const key = `${ch.key}-${month}`
          const budget = allocations[key] || 0
          const bm = benchmarkMap.get(key)
          if (!bm || budget <= 0) continue

          const clicks = budget / bm.cpc
          const leads = clicks * bm.cvr_lead
          const cars = clicks * bm.cvr_car

          perChannel.push({
            channel_key: ch.key,
            channel_label: ch.label,
            funnel_stage: stage,
            month_index: month,
            budget, cpc: bm.cpc, clicks, cvr_lead: bm.cvr_lead, leads, cvr_car: bm.cvr_car, cars,
          })

          byStage[stage].budget += budget
          byStage[stage].clicks += clicks
          byStage[stage].leads += leads
          byMonth[month].budget += budget
          byMonth[month].clicks += clicks
          byMonth[month].leads += leads
        }
      }
    }

    // Raw totals (before multipliers)
    const rawTotalBudget = Object.values(byStage).reduce((s, v) => s + v.budget, 0)
    const rawTotalLeads = Object.values(byStage).reduce((s, v) => s + v.leads, 0)

    // Funnel synergy multipliers
    const awPct = rawTotalBudget > 0 ? byStage.awareness.budget / rawTotalBudget : 0
    const coPct = rawTotalBudget > 0 ? byStage.consideration.budget / rawTotalBudget : 0
    const awMultiplier = awPct > AWARENESS_THRESHOLD ? AWARENESS_MULTIPLIER : 1
    const coMultiplier = coPct > CONSIDERATION_THRESHOLD ? CONSIDERATION_MULTIPLIER : 1
    const totalMultiplier = awMultiplier * coMultiplier

    const totalLeads = rawTotalLeads * totalMultiplier
    const rate = leadToSaleRate / 100
    const totalCars = totalLeads * rate

    const totals: SimTotals = {
      total_budget: rawTotalBudget,
      total_clicks: Object.values(byStage).reduce((s, v) => s + v.clicks, 0),
      total_leads: totalLeads,
      cost_per_lead: totalLeads > 0 ? rawTotalBudget / totalLeads : 0,
      total_cars: totalCars,
      cost_per_car: totalCars > 0 ? rawTotalBudget / totalCars : 0,
    }

    return {
      perChannel, byStage, byMonth, totals,
      awPct, coPct, awMultiplier, coMultiplier, totalMultiplier, rawTotalLeads,
    }
  }, [allocations, activeChannels, benchmarkMap, channelsByStage, leadToSaleRate])

  const budgetRemaining = totalBudget - outputs.totals.total_budget

  // ── Actions ──

  const handleAllocationChange = useCallback((channelKey: string, month: number, value: string) => {
    const num = parseFloat(value) || 0
    setAllocations(prev => ({ ...prev, [`${channelKey}-${month}`]: num }))
  }, [])

  const handleReset = useCallback(() => {
    setAllocations({})
  }, [])

  const handleAutoDistribute = useCallback(() => {
    const newAlloc: Record<string, number> = {}

    for (let mi = 0; mi < 3; mi++) {
      const month = mi + 1
      const monthBudget = totalBudget * AUTO_DISTRIBUTE.months[mi]
      const stageWeights = AUTO_DISTRIBUTE.stages[mi]

      for (const stage of STAGES) {
        const stageBudget = monthBudget * stageWeights[stage]
        const channels = (channelsByStage[stage] ?? []).filter(ch => activeChannels[ch.key])
        if (channels.length === 0) continue
        const perChannel = stageBudget / channels.length

        for (const ch of channels) {
          newAlloc[`${ch.key}-${month}`] = Math.round(perChannel * 100) / 100
        }
      }
    }

    setAllocations(newAlloc)
  }, [totalBudget, channelsByStage, activeChannels])

  const toggleChannel = useCallback((key: string) => {
    setActiveChannels(prev => {
      const next = { ...prev, [key]: !prev[key] }
      // Clear allocations for deactivated channel
      if (!next[key]) {
        setAllocations(prev2 => {
          const a = { ...prev2 }
          delete a[`${key}-1`]
          delete a[`${key}-2`]
          delete a[`${key}-3`]
          return a
        })
      }
      return next
    })
  }, [])

  const toggleStageCollapse = useCallback((stage: string) => {
    setCollapsedStages(prev => ({ ...prev, [stage]: !prev[stage] }))
  }, [])

  // ── Helpers for grid ──

  function getChannelMonthTotal(channelKey: string): { budget: number; clicks: number; leads: number } {
    let budget = 0, clicks = 0, leads = 0
    for (const month of [1, 2, 3]) {
      const b = allocations[`${channelKey}-${month}`] || 0
      const bm = benchmarkMap.get(`${channelKey}-${month}`)
      if (bm && b > 0) {
        budget += b
        const c = b / bm.cpc
        clicks += c
        leads += c * bm.cvr_lead
      }
    }
    return { budget, clicks, leads }
  }

  if (isLoading) {
    return (
      <div className="space-y-4 mt-4">
        <Skeleton className="h-32 w-full" />
        <Skeleton className="h-96 w-full" />
      </div>
    )
  }

  return (
    <TooltipProvider delayDuration={200}>
      <div className="space-y-4 mt-4">

        {/* ── Header: Inputs ── */}
        <Card>
          <CardContent className="pt-4 pb-4">
            <div className="flex flex-wrap items-end gap-4">
              <div className="space-y-1">
                <Label className="text-xs text-muted-foreground flex items-center gap-1">
                  <Users className="h-3 w-3" /> Audience Size
                </Label>
                <Input
                  type="number"
                  className="w-36 h-8 text-sm"
                  value={audienceSize}
                  onChange={e => setAudienceSize(parseInt(e.target.value) || 0)}
                />
              </div>
              <div className="space-y-1">
                <Label className="text-xs text-muted-foreground flex items-center gap-1">
                  <DollarSign className="h-3 w-3" /> Total Budget (EUR)
                </Label>
                <Input
                  type="number"
                  className="w-36 h-8 text-sm"
                  value={totalBudget}
                  onChange={e => setTotalBudget(parseFloat(e.target.value) || 0)}
                />
              </div>
              <div className="space-y-1">
                <Label className="text-xs text-muted-foreground flex items-center gap-1">
                  <Car className="h-3 w-3" /> Lead → Sale %
                </Label>
                <Input
                  type="number"
                  className="w-24 h-8 text-sm"
                  value={leadToSaleRate}
                  step={0.5}
                  onChange={e => setLeadToSaleRate(parseFloat(e.target.value) || 0)}
                />
              </div>

              <div className="flex gap-2 ml-auto">
                <Button variant="outline" size="sm" onClick={handleReset}>
                  <RotateCcw className="h-3.5 w-3.5 mr-1" /> Reset
                </Button>
                <Button size="sm" onClick={handleAutoDistribute}>
                  <Wand2 className="h-3.5 w-3.5 mr-1" /> Auto-Distribute
                </Button>
              </div>

              <div className="flex items-center gap-2">
                <span className="text-xs text-muted-foreground">Remaining:</span>
                <Badge variant={budgetRemaining < 0 ? 'destructive' : budgetRemaining === 0 ? 'default' : 'secondary'} className="text-xs">
                  {fmtEur(budgetRemaining)}
                </Badge>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* ── Allocation Grid ── */}
        <Card>
          <CardContent className="p-0">
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow className="text-xs">
                    <TableHead className="w-52 sticky left-0 bg-background z-10">Channel</TableHead>
                    <TableHead className="text-center w-24 bg-blue-50/50 dark:bg-blue-950/20">M1 Budget</TableHead>
                    <TableHead className="text-right w-20 bg-blue-50/50 dark:bg-blue-950/20">Clicks</TableHead>
                    <TableHead className="text-right w-20 bg-blue-50/50 dark:bg-blue-950/20">Leads</TableHead>
                    <TableHead className="text-center w-24 bg-amber-50/50 dark:bg-amber-950/20">M2 Budget</TableHead>
                    <TableHead className="text-right w-20 bg-amber-50/50 dark:bg-amber-950/20">Clicks</TableHead>
                    <TableHead className="text-right w-20 bg-amber-50/50 dark:bg-amber-950/20">Leads</TableHead>
                    <TableHead className="text-center w-24 bg-green-50/50 dark:bg-green-950/20">M3 Budget</TableHead>
                    <TableHead className="text-right w-20 bg-green-50/50 dark:bg-green-950/20">Clicks</TableHead>
                    <TableHead className="text-right w-20 bg-green-50/50 dark:bg-green-950/20">Leads</TableHead>
                    <TableHead className="text-right w-20 font-bold">Total €</TableHead>
                    <TableHead className="text-right w-20 font-bold">Clicks</TableHead>
                    <TableHead className="text-right w-20 font-bold">Leads</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {STAGES.map(stage => {
                    const cfg = STAGE_CONFIG[stage]
                    const channels = channelsByStage[stage] ?? []
                    const activeList = channels.filter(ch => activeChannels[ch.key])
                    const isCollapsed = collapsedStages[stage]

                    // Stage subtotals
                    const stageData = outputs.byStage[stage] || { budget: 0, clicks: 0, leads: 0 }

                    return (
                      <> {/* Fragment for stage group */}
                        {/* Stage Header */}
                        <TableRow
                          key={`stage-${stage}`}
                          className={cn(cfg.headerBg, cfg.textColor, 'cursor-pointer hover:opacity-90')}
                          onClick={() => toggleStageCollapse(stage)}
                        >
                          <TableCell colSpan={10} className="py-1.5 font-semibold text-xs sticky left-0">
                            <div className="flex items-center gap-2">
                              {isCollapsed ? <ChevronRight className="h-3.5 w-3.5" /> : <ChevronDown className="h-3.5 w-3.5" />}
                              {cfg.label}
                              <span className="font-normal opacity-80">({activeList.length}/{channels.length} channels)</span>
                              {/* Channel toggle */}
                              <Popover>
                                <PopoverTrigger asChild onClick={e => e.stopPropagation()}>
                                  <button className="ml-auto opacity-70 hover:opacity-100">
                                    <Plus className="h-3.5 w-3.5" />
                                  </button>
                                </PopoverTrigger>
                                <PopoverContent className="w-56 p-2" onClick={e => e.stopPropagation()}>
                                  <p className="text-xs font-medium mb-2">Toggle channels</p>
                                  {channels.map(ch => (
                                    <label key={ch.key} className="flex items-center gap-2 py-1 text-xs cursor-pointer hover:bg-accent rounded px-1">
                                      <Checkbox
                                        checked={!!activeChannels[ch.key]}
                                        onCheckedChange={() => toggleChannel(ch.key)}
                                      />
                                      {ch.label}
                                    </label>
                                  ))}
                                </PopoverContent>
                              </Popover>
                            </div>
                          </TableCell>
                          <TableCell className="text-right text-xs py-1.5 font-semibold">{fmtEur(stageData.budget)}</TableCell>
                          <TableCell className="text-right text-xs py-1.5 font-semibold">{fmtNum(stageData.clicks)}</TableCell>
                          <TableCell className="text-right text-xs py-1.5 font-semibold">{fmtNum(stageData.leads, 1)}</TableCell>
                        </TableRow>

                        {/* Channel Rows */}
                        {!isCollapsed && activeList.map(ch => {
                          const rowTotal = getChannelMonthTotal(ch.key)
                          return (
                            <TableRow key={ch.key} className={cn('text-xs', cfg.bg, 'hover:bg-accent/40')}>
                              <TableCell className="py-1 font-medium sticky left-0 bg-inherit text-xs">
                                {ch.label}
                              </TableCell>
                              {[1, 2, 3].map(month => {
                                const allocKey = `${ch.key}-${month}`
                                const bm = benchmarkMap.get(allocKey)
                                const budget = allocations[allocKey] || 0
                                const clicks = bm && budget > 0 ? budget / bm.cpc : 0
                                const leads = bm ? clicks * bm.cvr_lead : 0

                                return (
                                  <>
                                    <TableCell key={`${allocKey}-b`} className="py-1 text-center">
                                      <Input
                                        type="number"
                                        className="w-20 h-6 text-xs text-center px-1"
                                        value={budget || ''}
                                        placeholder="0"
                                        onChange={e => handleAllocationChange(ch.key, month, e.target.value)}
                                      />
                                    </TableCell>
                                    <TableCell key={`${allocKey}-c`} className="py-1 text-right text-muted-foreground">
                                      <Tooltip>
                                        <TooltipTrigger asChild>
                                          <span>{clicks > 0 ? fmtNum(clicks) : '-'}</span>
                                        </TooltipTrigger>
                                        <TooltipContent className="text-xs">
                                          CPC: {bm ? fmtEur(bm.cpc) : '-'}
                                        </TooltipContent>
                                      </Tooltip>
                                    </TableCell>
                                    <TableCell key={`${allocKey}-l`} className="py-1 text-right text-muted-foreground">
                                      <Tooltip>
                                        <TooltipTrigger asChild>
                                          <span>{leads > 0 ? fmtNum(leads, 2) : '-'}</span>
                                        </TooltipTrigger>
                                        <TooltipContent className="text-xs">
                                          CVR: {bm ? fmtPct(bm.cvr_lead) : '-'}
                                        </TooltipContent>
                                      </Tooltip>
                                    </TableCell>
                                  </>
                                )
                              })}
                              {/* Row totals */}
                              <TableCell className="py-1 text-right font-medium">{rowTotal.budget > 0 ? fmtEur(rowTotal.budget) : '-'}</TableCell>
                              <TableCell className="py-1 text-right text-muted-foreground">{rowTotal.clicks > 0 ? fmtNum(rowTotal.clicks) : '-'}</TableCell>
                              <TableCell className="py-1 text-right text-muted-foreground">{rowTotal.leads > 0 ? fmtNum(rowTotal.leads, 2) : '-'}</TableCell>
                            </TableRow>
                          )
                        })}
                      </>
                    )
                  })}

                  {/* Grand Total */}
                  <TableRow className="bg-gray-900 dark:bg-gray-100 text-white dark:text-gray-900 font-bold text-xs">
                    <TableCell className="py-2 sticky left-0 bg-inherit">GRAND TOTAL</TableCell>
                    {[1, 2, 3].map(month => {
                      const md = outputs.byMonth[month]
                      return (
                        <>
                          <TableCell key={`gt-${month}-b`} className="py-2 text-center">{fmtEur(md.budget)}</TableCell>
                          <TableCell key={`gt-${month}-c`} className="py-2 text-right">{fmtNum(md.clicks)}</TableCell>
                          <TableCell key={`gt-${month}-l`} className="py-2 text-right">{fmtNum(md.leads, 1)}</TableCell>
                        </>
                      )
                    })}
                    <TableCell className="py-2 text-right">{fmtEur(outputs.totals.total_budget)}</TableCell>
                    <TableCell className="py-2 text-right">{fmtNum(outputs.totals.total_clicks)}</TableCell>
                    <TableCell className="py-2 text-right">{fmtNum(outputs.rawTotalLeads, 1)}</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>

        {/* ── Synergy Multipliers ── */}
        {(outputs.awMultiplier > 1 || outputs.coMultiplier > 1) && (
          <Card className="border-amber-300 dark:border-amber-700 bg-amber-50/50 dark:bg-amber-950/20">
            <CardContent className="py-3">
              <div className="flex items-center gap-3 text-sm">
                <TrendingUp className="h-4 w-4 text-amber-600" />
                <span className="font-medium text-amber-800 dark:text-amber-200">Funnel Synergy Bonus Active!</span>
                <div className="flex gap-4 ml-2 text-xs">
                  {outputs.awMultiplier > 1 && (
                    <Badge variant="outline" className="border-blue-400 text-blue-700 dark:text-blue-300">
                      Awareness &gt;42% → {outputs.awMultiplier}x leads
                    </Badge>
                  )}
                  {outputs.coMultiplier > 1 && (
                    <Badge variant="outline" className="border-amber-400 text-amber-700 dark:text-amber-300">
                      Consideration &gt;14% → {outputs.coMultiplier}x leads
                    </Badge>
                  )}
                  <Badge className="bg-green-600 text-white">
                    Total: {outputs.totalMultiplier}x → {fmtNum(outputs.totals.total_leads, 1)} leads
                  </Badge>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        {/* ── Results Panel ── */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          <ResultCard
            icon={<Target className="h-4 w-4 text-green-600" />}
            label="Total Leads"
            value={fmtNum(outputs.totals.total_leads, 1)}
            sub={outputs.totalMultiplier > 1 ? `${fmtNum(outputs.rawTotalLeads, 1)} × ${outputs.totalMultiplier}x` : undefined}
            color="green"
          />
          <ResultCard
            icon={<DollarSign className="h-4 w-4 text-blue-600" />}
            label="Cost / Lead"
            value={outputs.totals.cost_per_lead > 0 ? fmtEur(outputs.totals.cost_per_lead) : '-'}
            color="blue"
          />
          <ResultCard
            icon={<Car className="h-4 w-4 text-purple-600" />}
            label="Cars Sold"
            value={fmtNum(outputs.totals.total_cars, 1)}
            sub={`${leadToSaleRate}% conversion`}
            color="purple"
          />
          <ResultCard
            icon={<DollarSign className="h-4 w-4 text-red-600" />}
            label="Cost / Car"
            value={outputs.totals.cost_per_car > 0 ? fmtEur(outputs.totals.cost_per_car) : '-'}
            color="red"
          />
        </div>

        {/* ── Funnel Visualization + Monthly Breakdown ── */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {/* Funnel */}
          <Card>
            <CardHeader className="py-3 px-4">
              <CardTitle className="text-sm flex items-center gap-2">
                <TrendingUp className="h-4 w-4" /> Funnel Flow
              </CardTitle>
            </CardHeader>
            <CardContent className="pb-4 px-4">
              <FunnelVis
                audience={audienceSize}
                clicks={outputs.totals.total_clicks}
                leads={outputs.totals.total_leads}
                cars={outputs.totals.total_cars}
              />
            </CardContent>
          </Card>

          {/* Monthly Breakdown */}
          <Card>
            <CardHeader className="py-3 px-4">
              <CardTitle className="text-sm flex items-center gap-2">
                <Calculator className="h-4 w-4" /> Monthly Breakdown
              </CardTitle>
            </CardHeader>
            <CardContent className="pb-4 px-4">
              <div className="grid grid-cols-3 gap-3">
                {[1, 2, 3].map(month => {
                  const md = outputs.byMonth[month]
                  const pct = outputs.totals.total_budget > 0 ? (md.budget / outputs.totals.total_budget * 100) : 0
                  return (
                    <div key={month} className="rounded-lg border p-3 text-center space-y-2">
                      <p className="text-xs font-semibold text-muted-foreground">Month {month}</p>
                      <p className="text-lg font-bold">{fmtEur(md.budget)}</p>
                      <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-1.5">
                        <div className="bg-blue-600 h-1.5 rounded-full" style={{ width: `${Math.min(pct, 100)}%` }} />
                      </div>
                      <div className="grid grid-cols-2 gap-1 text-xs text-muted-foreground">
                        <span>{fmtNum(md.clicks)} clicks</span>
                        <span>{fmtNum(md.leads, 1)} leads</span>
                      </div>
                    </div>
                  )
                })}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* ── Info ── */}
        <div className="text-xs text-muted-foreground flex items-start gap-2 px-1">
          <Info className="h-3.5 w-3.5 mt-0.5 shrink-0" />
          <span>
            Benchmarks sourced from Toyota Digital Masterclass (Romanian automotive market). CPC and CVR rates
            vary by month to model audience fatigue (awareness) and retargeting lift (consideration/conversion).
            Funnel synergy: spending &gt;42% on awareness gives a 1.7x lead multiplier; &gt;14% on consideration gives 1.5x.
            These stack for up to 2.55x total.
          </span>
        </div>
      </div>
    </TooltipProvider>
  )
}

// ── Sub-components ──

function ResultCard({ icon, label, value, sub }: {
  icon: React.ReactNode
  label: string
  value: string
  sub?: string
  color?: string
}) {
  return (
    <Card>
      <CardContent className="py-3 px-4">
        <div className="flex items-center gap-2 mb-1">
          {icon}
          <span className="text-xs text-muted-foreground">{label}</span>
        </div>
        <p className="text-xl font-bold">{value}</p>
        {sub && <p className="text-xs text-muted-foreground mt-0.5">{sub}</p>}
      </CardContent>
    </Card>
  )
}

function FunnelVis({ audience, clicks, leads, cars }: {
  audience: number
  clicks: number
  leads: number
  cars: number
}) {
  const steps = [
    { label: 'Audience', value: audience, color: 'bg-blue-500' },
    { label: 'Clicks', value: clicks, color: 'bg-amber-500' },
    { label: 'Leads', value: leads, color: 'bg-green-500' },
    { label: 'Cars Sold', value: cars, color: 'bg-purple-500' },
  ]
  const maxVal = Math.max(audience, 1)

  return (
    <div className="space-y-2">
      {steps.map((step) => {
        const widthPct = Math.max((step.value / maxVal) * 100, 4)
        return (
          <div key={step.label} className="flex items-center gap-3">
            <span className="text-xs w-16 text-right text-muted-foreground shrink-0">{step.label}</span>
            <div className="flex-1 flex items-center gap-2">
              <div
                className={cn('h-6 rounded flex items-center justify-end px-2 transition-all', step.color)}
                style={{ width: `${widthPct}%` }}
              >
                <span className="text-[10px] font-semibold text-white whitespace-nowrap">
                  {fmtNum(step.value, step.value < 100 ? 1 : 0)}
                </span>
              </div>
            </div>
          </div>
        )
      })}
    </div>
  )
}
